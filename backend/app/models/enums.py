from enum import Enum
from typing import Type

from sqlalchemy import Enum as SqlEnum


class GoalStatus(str, Enum):
    IN_REVIEW = "inReview"
    ACTIVE = "active"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class BetSide(str, Enum):
    FOR_GOAL = "forGoal"
    AGAINST_GOAL = "againstGoal"


class BetSource(str, Enum):
    AUTHOR_AUTO_SUPPORT = "author_auto_support"
    MANUAL = "manual"


class EvidenceAttachmentType(str, Enum):
    IMAGE = "image"
    VIDEO = "video"


class ArbitrationDecision(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"


class WalletTransactionType(str, Enum):
    INITIAL_BALANCE = "INITIAL_BALANCE"
    BET_STAKE_DEBIT = "BET_STAKE_DEBIT"
    GOAL_POOL_PAYOUT = "GOAL_POOL_PAYOUT"
    REFUND = "REFUND"
    MANUAL_ADJUSTMENT = "MANUAL_ADJUSTMENT"


class RatingTransactionReason(str, Enum):
    GOAL_COMPLETED = "GOAL_COMPLETED"
    GOAL_FAILED = "GOAL_FAILED"
    BET_WON = "BET_WON"
    BET_LOST = "BET_LOST"
    MANUAL_ADJUSTMENT = "MANUAL_ADJUSTMENT"


def enum_column(enum_cls: Type[Enum], name: str) -> SqlEnum:
    return SqlEnum(
        enum_cls,
        name=name,
        values_callable=lambda values: [item.value for item in values],
        validate_strings=True,
    )
