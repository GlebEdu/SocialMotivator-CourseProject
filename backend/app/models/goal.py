from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Index, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import GoalStatus, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class Goal(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "goals"
    __table_args__ = (
        CheckConstraint("title <> ''", name="goals_title_not_empty"),
        CheckConstraint("description <> ''", name="goals_description_not_empty"),
        Index("ix_goals_status_deadline_at", "status", "deadline_at"),
        Index("ix_goals_created_at", "created_at"),
        Index("ix_goals_user_id_created_at", "user_id", "created_at"),
    )

    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[GoalStatus] = mapped_column(
        enum_column(GoalStatus, "goal_status"),
        nullable=False,
    )
    deadline_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    resolution_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    user: Mapped["User"] = relationship(back_populates="goals")
    bets: Mapped[list["Bet"]] = relationship(back_populates="goal")
    evidence_items: Mapped[list["Evidence"]] = relationship(back_populates="goal")
    arbitration_cases: Mapped[list["ArbitrationCase"]] = relationship(back_populates="goal")
    wallet_transactions: Mapped[list["WalletTransaction"]] = relationship(back_populates="goal")
    rating_transactions: Mapped[list["RatingTransaction"]] = relationship(back_populates="goal")
