from decimal import Decimal
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.bet import Bet
from app.models.enums import BetSide, BetSource, GoalStatus, WalletTransactionType
from app.models.goal import Goal
from app.models.user import User
from app.models.wallet_transaction import WalletTransaction
from app.schemas.goals import BetDto, CreateGoalRequest, CreateGoalResponse
from app.schemas.read_models import GoalSnapshotDto

AUTHOR_AUTO_SUPPORT_AMOUNT = Decimal("10.00")


def create_goal(
    db: Session,
    current_user_id: UUID,
    payload: CreateGoalRequest,
) -> CreateGoalResponse:
    try:
        user = db.execute(
            select(User).where(User.id == current_user_id).with_for_update()
        ).scalar_one_or_none()
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials.",
            )

        if user.balance < AUTHOR_AUTO_SUPPORT_AMOUNT:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient balance for the mandatory author support bet.",
            )

        goal = Goal(
            user_id=user.id,
            title=payload.title,
            description=payload.description,
            status=GoalStatus.ACTIVE,
            deadline_at=payload.deadline_at(),
        )
        db.add(goal)
        db.flush()

        author_auto_bet = Bet(
            goal_id=goal.id,
            user_id=user.id,
            side=BetSide.FOR_GOAL,
            amount=AUTHOR_AUTO_SUPPORT_AMOUNT,
            source=BetSource.AUTHOR_AUTO_SUPPORT,
        )
        db.add(author_auto_bet)
        db.flush()

        balance_before = user.balance
        balance_after = balance_before - AUTHOR_AUTO_SUPPORT_AMOUNT
        user.balance = balance_after

        wallet_transaction = WalletTransaction(
            user_id=user.id,
            type=WalletTransactionType.BET_STAKE_DEBIT,
            amount=-AUTHOR_AUTO_SUPPORT_AMOUNT,
            balance_before=balance_before,
            balance_after=balance_after,
            goal_id=goal.id,
            bet_id=author_auto_bet.id,
            reference_key=f"goal:{goal.id}:author-auto-support",
        )
        db.add(wallet_transaction)

        db.commit()
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise

    db.refresh(goal)
    db.refresh(author_auto_bet)

    return CreateGoalResponse(
        goal=GoalSnapshotDto(
            id=goal.id,
            user_id=goal.user_id,
            title=goal.title,
            description=goal.description,
            status=goal.status,
            created_at=goal.created_at,
            deadline=goal.deadline_at,
        ),
        author_auto_bet=BetDto(
            id=author_auto_bet.id,
            goal_id=author_auto_bet.goal_id,
            user_id=author_auto_bet.user_id,
            side=author_auto_bet.side,
            amount=float(author_auto_bet.amount),
            created_at=author_auto_bet.created_at,
        ),
    )
