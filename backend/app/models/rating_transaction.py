from typing import Optional
from uuid import UUID

from sqlalchemy import CheckConstraint, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import RatingTransactionReason, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class RatingTransaction(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "rating_transactions"
    __table_args__ = (
        CheckConstraint(
            "rating_after >= 0",
            name="rating_transactions_rating_after_non_negative",
        ),
        Index("ix_rating_transactions_user_id_created_at", "user_id", "created_at"),
    )

    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    reason: Mapped[RatingTransactionReason] = mapped_column(
        enum_column(RatingTransactionReason, "rating_transaction_reason"),
        nullable=False,
    )
    delta: Mapped[int] = mapped_column(nullable=False)
    rating_before: Mapped[int] = mapped_column(nullable=False)
    rating_after: Mapped[int] = mapped_column(nullable=False)
    goal_id: Mapped[Optional[UUID]] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("goals.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    bet_id: Mapped[Optional[UUID]] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("bets.id", ondelete="SET NULL"),
        nullable=True,
    )
    arbitration_case_id: Mapped[Optional[UUID]] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("arbitration_cases.id", ondelete="SET NULL"),
        nullable=True,
    )

    user: Mapped["User"] = relationship(back_populates="rating_transactions")
    goal: Mapped["Goal"] = relationship(back_populates="rating_transactions")
    bet: Mapped["Bet"] = relationship(back_populates="rating_transactions")
    arbitration_case: Mapped["ArbitrationCase"] = relationship(back_populates="rating_transactions")
