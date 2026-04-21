from decimal import Decimal
from uuid import UUID

from sqlalchemy import CheckConstraint, ForeignKey, Index, Numeric
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import BetSide, BetSource, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class Bet(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "bets"
    __table_args__ = (
        CheckConstraint("amount > 0", name="bets_amount_positive"),
        Index("ix_bets_goal_id_side", "goal_id", "side"),
        Index("ix_bets_goal_id_created_at", "goal_id", "created_at"),
    )

    goal_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("goals.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    side: Mapped[BetSide] = mapped_column(
        enum_column(BetSide, "bet_side"),
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
    source: Mapped[BetSource] = mapped_column(
        enum_column(BetSource, "bet_source"),
        nullable=False,
    )

    goal: Mapped["Goal"] = relationship(back_populates="bets")
    user: Mapped["User"] = relationship(back_populates="bets")
    wallet_transactions: Mapped[list["WalletTransaction"]] = relationship(back_populates="bet")
    rating_transactions: Mapped[list["RatingTransaction"]] = relationship(back_populates="bet")
