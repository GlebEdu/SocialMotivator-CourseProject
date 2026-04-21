from uuid import UUID
from typing import Optional

from sqlalchemy import BigInteger, CheckConstraint, ForeignKey, Index, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.enums import EvidenceAttachmentType, enum_column
from app.models.mixins import CreatedAtMixin, UUIDPrimaryKeyMixin


class Evidence(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "evidence"
    __table_args__ = (
        CheckConstraint("description <> ''", name="evidence_description_not_empty"),
        Index("ix_evidence_goal_id_created_at", "goal_id", "created_at"),
    )

    goal_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("goals.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    submitted_by_user_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)

    goal: Mapped["Goal"] = relationship(back_populates="evidence_items")
    submitted_by_user: Mapped["User"] = relationship(back_populates="evidence_items")
    files: Mapped[list["EvidenceFile"]] = relationship(back_populates="evidence")


class EvidenceFile(UUIDPrimaryKeyMixin, CreatedAtMixin, Base):
    __tablename__ = "evidence_files"
    __table_args__ = (
        CheckConstraint(
            "file_size_bytes IS NULL OR file_size_bytes >= 0",
            name="evidence_files_size_non_negative",
        ),
    )

    evidence_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("evidence.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )
    type: Mapped[EvidenceAttachmentType] = mapped_column(
        enum_column(EvidenceAttachmentType, "evidence_attachment_type"),
        nullable=False,
    )
    storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    url: Mapped[str] = mapped_column(Text, nullable=False)
    mime_type: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    file_name: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    file_size_bytes: Mapped[Optional[int]] = mapped_column(BigInteger, nullable=True)

    evidence: Mapped["Evidence"] = relationship(back_populates="files")
