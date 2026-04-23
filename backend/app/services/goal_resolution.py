from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal, ROUND_DOWN
from typing import Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.arbitration import ArbitrationCase
from app.models.bet import Bet
from app.models.enums import (
    BetSide,
    GoalStatus,
    RatingTransactionReason,
    WalletTransactionType,
)
from app.models.evidence import Evidence
from app.models.goal import Goal
from app.models.rating_transaction import RatingTransaction
from app.models.user import User
from app.models.wallet_transaction import WalletTransaction

GOAL_SUCCESS_RATING_DELTA = 15
GOAL_FAILURE_RATING_DELTA = -10
WINNING_BET_RATING_DELTA = 5
LOSING_BET_RATING_DELTA = -3
MONEY_QUANT = Decimal("0.01")


def expire_overdue_goals(db: Session, *, now: Optional[datetime] = None) -> int:
    """Resolve active goals whose full deadline day has already passed."""
    current_time = now or datetime.now(timezone.utc)
    cutoff = datetime(
        current_time.year,
        current_time.month,
        current_time.day,
        tzinfo=timezone.utc,
    )
    evidence_exists = (
        select(Evidence.id)
        .where(Evidence.goal_id == Goal.id)
        .limit(1)
        .exists()
    )

    goals = db.scalars(
        select(Goal)
        .where(Goal.status == GoalStatus.ACTIVE)
        .where(Goal.deadline_at.is_not(None))
        .where(Goal.deadline_at < cutoff)
        .where(~evidence_exists)
        .order_by(Goal.deadline_at.asc(), Goal.id.asc())
        .with_for_update()
    ).all()
    if not goals:
        return 0

    try:
        for goal in goals:
            resolve_goal(
                db,
                goal=goal,
                status=GoalStatus.FAILED,
                resolved_at=current_time,
                reason="Deadline passed without submitted evidence.",
                reference_prefix=f"deadline:{goal.id}",
            )
        db.commit()
    except Exception:
        db.rollback()
        raise

    return len(goals)


def resolve_goal(
    db: Session,
    *,
    goal: Goal,
    status: GoalStatus,
    resolved_at: datetime,
    reason: str,
    arbitration_case: ArbitrationCase | None = None,
    reference_prefix: str | None = None,
) -> GoalStatus:
    goal.status = status
    goal.resolved_at = resolved_at
    goal.resolution_reason = reason

    bets = db.scalars(
        select(Bet)
        .where(Bet.goal_id == goal.id)
        .order_by(Bet.created_at.asc(), Bet.id.asc())
    ).all()
    _write_payouts(
        db,
        goal=goal,
        bets=bets,
        arbitration_case=arbitration_case,
        reference_prefix=reference_prefix or f"goal:{goal.id}:resolution",
    )
    _write_rating_updates(
        db,
        goal=goal,
        bets=bets,
        arbitration_case=arbitration_case,
    )
    return status


def _write_payouts(
    db: Session,
    *,
    goal: Goal,
    bets: list[Bet],
    arbitration_case: ArbitrationCase | None,
    reference_prefix: str,
) -> None:
    winning_side = _winning_side_for_status(goal.status)
    if winning_side is None or not bets:
        return

    winning_bets = [bet for bet in bets if bet.side == winning_side]
    if not winning_bets:
        return

    total_pool = sum((bet.amount for bet in bets), Decimal("0.00"))
    winning_pool = sum((bet.amount for bet in winning_bets), Decimal("0.00"))
    distributed = Decimal("0.00")
    user_cache: dict[UUID, User] = {}

    for index, bet in enumerate(winning_bets):
        is_last_winner = index == len(winning_bets) - 1
        if is_last_winner:
            payout = total_pool - distributed
        else:
            payout = (total_pool * bet.amount / winning_pool).quantize(
                MONEY_QUANT,
                rounding=ROUND_DOWN,
            )
            distributed += payout

        if payout <= 0:
            continue

        winner = _get_locked_user(db, user_cache, bet.user_id)
        balance_before = winner.balance
        balance_after = balance_before + payout
        winner.balance = balance_after

        db.add(
            WalletTransaction(
                user_id=winner.id,
                type=WalletTransactionType.GOAL_POOL_PAYOUT,
                amount=payout,
                balance_before=balance_before,
                balance_after=balance_after,
                goal_id=goal.id,
                bet_id=bet.id,
                arbitration_case_id=arbitration_case.id if arbitration_case else None,
                reference_key=f"{reference_prefix}:bet:{bet.id}:payout",
            )
        )


def _write_rating_updates(
    db: Session,
    *,
    goal: Goal,
    bets: list[Bet],
    arbitration_case: ArbitrationCase | None,
) -> None:
    author_reason = (
        RatingTransactionReason.GOAL_COMPLETED
        if goal.status == GoalStatus.COMPLETED
        else RatingTransactionReason.GOAL_FAILED
    )
    author_delta = (
        GOAL_SUCCESS_RATING_DELTA
        if goal.status == GoalStatus.COMPLETED
        else GOAL_FAILURE_RATING_DELTA
    )

    user_cache: dict[UUID, User] = {}
    author = _get_locked_user(db, user_cache, goal.user_id)
    _apply_rating_transaction(
        db,
        user=author,
        delta=author_delta,
        reason=author_reason,
        goal_id=goal.id,
        arbitration_case_id=arbitration_case.id if arbitration_case else None,
    )

    winning_side = _winning_side_for_status(goal.status)
    if winning_side is None:
        return

    for bet in bets:
        bettor = _get_locked_user(db, user_cache, bet.user_id)
        reason = (
            RatingTransactionReason.BET_WON
            if bet.side == winning_side
            else RatingTransactionReason.BET_LOST
        )
        delta = (
            WINNING_BET_RATING_DELTA
            if bet.side == winning_side
            else LOSING_BET_RATING_DELTA
        )
        _apply_rating_transaction(
            db,
            user=bettor,
            delta=delta,
            reason=reason,
            goal_id=goal.id,
            bet_id=bet.id,
            arbitration_case_id=arbitration_case.id if arbitration_case else None,
        )


def _apply_rating_transaction(
    db: Session,
    *,
    user: User,
    delta: int,
    reason: RatingTransactionReason,
    goal_id: UUID,
    arbitration_case_id: UUID | None,
    bet_id: UUID | None = None,
) -> None:
    rating_before = user.rating
    rating_after = max(0, rating_before + delta)
    applied_delta = rating_after - rating_before
    user.rating = rating_after

    db.add(
        RatingTransaction(
            user_id=user.id,
            reason=reason,
            delta=applied_delta,
            rating_before=rating_before,
            rating_after=rating_after,
            goal_id=goal_id,
            bet_id=bet_id,
            arbitration_case_id=arbitration_case_id,
        )
    )


def _get_locked_user(
    db: Session,
    cache: dict[UUID, User],
    user_id: UUID,
) -> User:
    user = cache.get(user_id)
    if user is not None:
        return user

    user = db.execute(
        select(User)
        .where(User.id == user_id)
        .with_for_update()
    ).scalar_one()
    cache[user_id] = user
    return user


def _winning_side_for_status(goal_status: GoalStatus) -> BetSide | None:
    if goal_status == GoalStatus.COMPLETED:
        return BetSide.FOR_GOAL
    if goal_status == GoalStatus.FAILED:
        return BetSide.AGAINST_GOAL
    return None
