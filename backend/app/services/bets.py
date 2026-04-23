from decimal import Decimal
from typing import Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.bet import Bet
from app.models.enums import BetSource, GoalStatus, WalletTransactionType
from app.models.goal import Goal
from app.models.user import User
from app.models.wallet_transaction import WalletTransaction
from app.schemas.bets import BetDto, PlaceBetRequest, PlaceBetResponse
from app.services.goal_resolution import expire_overdue_goals
from app.services.read_models import deadline_has_passed, get_goal_bet_summary


def place_bet(
    db: Session,
    goal_id: UUID,
    current_user_id: UUID,
    payload: PlaceBetRequest,
) -> PlaceBetResponse:
    expire_overdue_goals(db)
    try:
        goal = db.get(Goal, goal_id)
        if goal is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found.",
            )

        if goal.status != GoalStatus.ACTIVE or deadline_has_passed(goal.deadline_at):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Goal is no longer bettable.",
            )

        user = db.execute(
            select(User).where(User.id == current_user_id).with_for_update()
        ).scalar_one_or_none()
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials.",
            )

        amount = _normalize_amount(payload.amount)
        if user.balance < amount:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient balance to place this bet.",
            )

        bet = Bet(
            goal_id=goal.id,
            user_id=user.id,
            side=payload.side,
            amount=amount,
            source=BetSource.MANUAL,
        )
        db.add(bet)
        db.flush()

        balance_before = user.balance
        balance_after = balance_before - amount
        user.balance = balance_after

        db.add(
            WalletTransaction(
                user_id=user.id,
                type=WalletTransactionType.BET_STAKE_DEBIT,
                amount=-amount,
                balance_before=balance_before,
                balance_after=balance_after,
                goal_id=goal.id,
                bet_id=bet.id,
                reference_key=f"bet:{bet.id}:stake-debit",
            )
        )

        db.commit()
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise

    db.refresh(bet)

    return PlaceBetResponse(
        bet=BetDto(
            id=bet.id,
            goal_id=bet.goal_id,
            user_id=bet.user_id,
            side=bet.side,
            amount=float(bet.amount),
            created_at=bet.created_at,
        ),
        updated_bet_summary=get_goal_bet_summary(
            db=db,
            goal_id=goal.id,
            viewer_id=user.id,
        ),
        updated_balance=float(user.balance),
    )


def get_current_user_bets(
    db: Session,
    current_user_id: UUID,
    *,
    goal_id: Optional[UUID] = None,
) -> list[BetDto]:
    expire_overdue_goals(db)
    stmt = select(Bet).where(Bet.user_id == current_user_id)
    if goal_id is not None:
        stmt = stmt.where(Bet.goal_id == goal_id)

    bets = db.scalars(stmt.order_by(Bet.created_at.desc(), Bet.id.desc())).all()
    return [
        BetDto(
            id=bet.id,
            goal_id=bet.goal_id,
            user_id=bet.user_id,
            side=bet.side,
            amount=float(bet.amount),
            created_at=bet.created_at,
        )
        for bet in bets
    ]


def _normalize_amount(amount: Decimal) -> Decimal:
    return amount.quantize(Decimal("0.01"))
