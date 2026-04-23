"""allow_multiple_evidence_files

Revision ID: 8b4e2f1a9c3d
Revises: 0bc0f2a158f2
Create Date: 2026-04-23 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


# revision identifiers, used by Alembic.
revision: str = "8b4e2f1a9c3d"
down_revision: Union[str, Sequence[str], None] = "0bc0f2a158f2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Allow one evidence record to reference multiple uploaded files."""
    op.drop_index(op.f("ix_evidence_files_evidence_id"), table_name="evidence_files")
    op.create_index(
        op.f("ix_evidence_files_evidence_id"),
        "evidence_files",
        ["evidence_id"],
        unique=False,
    )


def downgrade() -> None:
    """Restore the previous single-file evidence constraint."""
    op.drop_index(op.f("ix_evidence_files_evidence_id"), table_name="evidence_files")
    op.create_index(
        op.f("ix_evidence_files_evidence_id"),
        "evidence_files",
        ["evidence_id"],
        unique=True,
    )
