from datetime import datetime
from decimal import Decimal
from typing import Optional

from sqlalchemy import Boolean, CheckConstraint, DateTime, Integer, Numeric, Text, text
from sqlalchemy.dialects.postgresql import CITEXT
from sqlalchemy.orm import Mapped, relationship, mapped_column

from app.db.base import Base
from app.models.mixins import TimestampMixin, UUIDPrimaryKeyMixin


class User(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "users"
    __table_args__ = (
        CheckConstraint("balance >= 0", name="users_balance_non_negative"),
        CheckConstraint("rating >= 0", name="users_rating_non_negative"),
    )

    email: Mapped[str] = mapped_column(CITEXT(), nullable=False, unique=True, index=True)
    display_name: Mapped[str] = mapped_column(Text, nullable=False)
    avatar_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    password_hash: Mapped[str] = mapped_column(Text, nullable=False)
    balance: Mapped[Decimal] = mapped_column(
        Numeric(14, 2),
        nullable=False,
        server_default=text("1000.00"),
    )
    rating: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        server_default=text("1000"),
    )
    last_login_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        server_default=text("true"),
    )

    goals: Mapped[list["Goal"]] = relationship(back_populates="user")
    bets: Mapped[list["Bet"]] = relationship(back_populates="user")
    evidence_items: Mapped[list["Evidence"]] = relationship(back_populates="submitted_by_user")
    created_arbitration_cases: Mapped[list["ArbitrationCase"]] = relationship(
        back_populates="created_by_user"
    )
    arbitration_assignments: Mapped[list["ArbitrationAssignment"]] = relationship(
        back_populates="user"
    )
    arbitration_votes: Mapped[list["ArbitrationVote"]] = relationship(back_populates="voter_user")
    wallet_transactions: Mapped[list["WalletTransaction"]] = relationship(back_populates="user")
    rating_transactions: Mapped[list["RatingTransaction"]] = relationship(back_populates="user")
