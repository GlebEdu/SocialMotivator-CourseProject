from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    Text,
    UniqueConstraint,
    text,
)
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.sql import func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import ArbitrationDecision, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class ArbitrationCase(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "arbitration_cases"
    __table_args__ = (
        CheckConstraint("reason <> ''", name="arbitration_cases_reason_not_empty"),
        CheckConstraint(
            "(decision = 'pending' AND resolved_at IS NULL) OR decision <> 'pending'",
            name="arbitration_cases_pending_resolution",
        ),
        Index("ix_arbitration_cases_decision_created_at", "decision", "created_at"),
        Index(
            "ux_arbitration_cases_goal_id_pending",
            "goal_id",
            unique=True,
            postgresql_where=text("decision = 'pending'"),
        ),
    )

    goal_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("goals.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_by_user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    decision: Mapped[ArbitrationDecision] = mapped_column(
        enum_column(ArbitrationDecision, "arbitration_decision"),
        nullable=False,
    )
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    goal: Mapped["Goal"] = relationship(back_populates="arbitration_cases")
    created_by_user: Mapped["User"] = relationship(back_populates="created_arbitration_cases")
    assignments: Mapped[list["ArbitrationAssignment"]] = relationship(back_populates="arbitration_case")
    votes: Mapped[list["ArbitrationVote"]] = relationship(back_populates="arbitration_case")
    wallet_transactions: Mapped[list["WalletTransaction"]] = relationship(
        back_populates="arbitration_case"
    )
    rating_transactions: Mapped[list["RatingTransaction"]] = relationship(
        back_populates="arbitration_case"
    )


class ArbitrationAssignment(UUIDPrimaryKeyMixin, Base):
    __tablename__ = "arbitration_assignments"
    __table_args__ = (
        UniqueConstraint("case_id", "user_id"),
        Index("ix_arbitration_assignments_user_id_has_voted", "user_id", "has_voted"),
    )

    case_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("arbitration_cases.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    has_voted: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("false"),
    )

    arbitration_case: Mapped["ArbitrationCase"] = relationship(back_populates="assignments")
    user: Mapped["User"] = relationship(back_populates="arbitration_assignments")


class ArbitrationVote(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "arbitration_votes"
    __table_args__ = (
        UniqueConstraint("case_id", "voter_user_id"),
        CheckConstraint(
            "decision IN ('approved', 'rejected')",
            name="arbitration_votes_decision_resolved_only",
        ),
    )

    case_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("arbitration_cases.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    voter_user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    decision: Mapped[ArbitrationDecision] = mapped_column(
        enum_column(ArbitrationDecision, "arbitration_decision"),
        nullable=False,
    )
    comment: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    arbitration_case: Mapped["ArbitrationCase"] = relationship(back_populates="votes")
    voter_user: Mapped["User"] = relationship(back_populates="arbitration_votes")
