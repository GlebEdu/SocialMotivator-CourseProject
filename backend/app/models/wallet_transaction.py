from decimal import Decimal
from typing import Optional
from uuid import UUID

from sqlalchemy import CheckConstraint, ForeignKey, Index, Numeric, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import WalletTransactionType, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class WalletTransaction(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "wallet_transactions"
    __table_args__ = (
        CheckConstraint(
            "balance_after >= 0",
            name="wallet_transactions_balance_after_non_negative",
        ),
        Index("ix_wallet_transactions_user_id_created_at", "user_id", "created_at"),
    )

    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    type: Mapped[WalletTransactionType] = mapped_column(
        enum_column(WalletTransactionType, "wallet_transaction_type"),
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
    balance_before: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
    balance_after: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
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
    reference_key: Mapped[Optional[str]] = mapped_column(Text, nullable=True, unique=True)

    user: Mapped["User"] = relationship(back_populates="wallet_transactions")
    goal: Mapped["Goal"] = relationship(back_populates="wallet_transactions")
    bet: Mapped["Bet"] = relationship(back_populates="wallet_transactions")
    arbitration_case: Mapped["ArbitrationCase"] = relationship(back_populates="wallet_transactions")
