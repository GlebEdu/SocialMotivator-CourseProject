"""initial_schema

Revision ID: 0bc0f2a158f2
Revises: 
Create Date: 2026-04-21 13:35:33.396904

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


goal_status = postgresql.ENUM(
    "inReview",
    "active",
    "completed",
    "failed",
    name="goal_status",
    create_type=False,
)
bet_side = postgresql.ENUM("forGoal", "againstGoal", name="bet_side", create_type=False)
bet_source = postgresql.ENUM(
    "author_auto_support",
    "manual",
    name="bet_source",
    create_type=False,
)
evidence_attachment_type = postgresql.ENUM(
    "image",
    "video",
    name="evidence_attachment_type",
    create_type=False,
)
arbitration_decision = postgresql.ENUM(
    "pending",
    "approved",
    "rejected",
    name="arbitration_decision",
    create_type=False,
)
wallet_transaction_type = postgresql.ENUM(
    "INITIAL_BALANCE",
    "BET_STAKE_DEBIT",
    "GOAL_POOL_PAYOUT",
    "REFUND",
    "MANUAL_ADJUSTMENT",
    name="wallet_transaction_type",
    create_type=False,
)
rating_transaction_reason = postgresql.ENUM(
    "GOAL_COMPLETED",
    "GOAL_FAILED",
    "BET_WON",
    "BET_LOST",
    "MANUAL_ADJUSTMENT",
    name="rating_transaction_reason",
    create_type=False,
)


# revision identifiers, used by Alembic.
revision: str = '0bc0f2a158f2'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    bind = op.get_bind()

    op.execute("CREATE EXTENSION IF NOT EXISTS citext")

    goal_status.create(bind, checkfirst=True)
    bet_side.create(bind, checkfirst=True)
    bet_source.create(bind, checkfirst=True)
    evidence_attachment_type.create(bind, checkfirst=True)
    arbitration_decision.create(bind, checkfirst=True)
    wallet_transaction_type.create(bind, checkfirst=True)
    rating_transaction_reason.create(bind, checkfirst=True)

    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("email", postgresql.CITEXT(), nullable=False),
        sa.Column("display_name", sa.Text(), nullable=False),
        sa.Column("avatar_url", sa.Text(), nullable=True),
        sa.Column("password_hash", sa.Text(), nullable=False),
        sa.Column("balance", sa.Numeric(14, 2), server_default=sa.text("1000.00"), nullable=False),
        sa.Column("rating", sa.Integer(), server_default=sa.text("1000"), nullable=False),
        sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.CheckConstraint("balance >= 0", name=op.f("ck_users_users_balance_non_negative")),
        sa.CheckConstraint("rating >= 0", name=op.f("ck_users_users_rating_non_negative")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_users")),
    )
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)

    op.create_table(
        "goals",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.Text(), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("status", goal_status, nullable=False),
        sa.Column("deadline_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("resolution_reason", sa.Text(), nullable=True),
        sa.CheckConstraint("title <> ''", name=op.f("ck_goals_goals_title_not_empty")),
        sa.CheckConstraint("description <> ''", name=op.f("ck_goals_goals_description_not_empty")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_goals_user_id_users"), ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_goals")),
    )
    op.create_index(op.f("ix_goals_user_id"), "goals", ["user_id"], unique=False)
    op.create_index("ix_goals_status_deadline_at", "goals", ["status", "deadline_at"], unique=False)
    op.create_index("ix_goals_created_at", "goals", ["created_at"], unique=False)
    op.create_index("ix_goals_user_id_created_at", "goals", ["user_id", "created_at"], unique=False)

    op.create_table(
        "bets",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("goal_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("side", bet_side, nullable=False),
        sa.Column("amount", sa.Numeric(14, 2), nullable=False),
        sa.Column("source", bet_source, nullable=False),
        sa.CheckConstraint("amount > 0", name=op.f("ck_bets_bets_amount_positive")),
        sa.ForeignKeyConstraint(["goal_id"], ["goals.id"], name=op.f("fk_bets_goal_id_goals"), ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name=op.f("fk_bets_user_id_users"), ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_bets")),
    )
    op.create_index(op.f("ix_bets_goal_id"), "bets", ["goal_id"], unique=False)
    op.create_index(op.f("ix_bets_user_id"), "bets", ["user_id"], unique=False)
    op.create_index("ix_bets_goal_id_side", "bets", ["goal_id", "side"], unique=False)
    op.create_index("ix_bets_goal_id_created_at", "bets", ["goal_id", "created_at"], unique=False)

    op.create_table(
        "evidence",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("goal_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("submitted_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.CheckConstraint("description <> ''", name=op.f("ck_evidence_evidence_description_not_empty")),
        sa.ForeignKeyConstraint(["goal_id"], ["goals.id"], name=op.f("fk_evidence_goal_id_goals"), ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["submitted_by_user_id"],
            ["users.id"],
            name=op.f("fk_evidence_submitted_by_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_evidence")),
    )
    op.create_index(op.f("ix_evidence_goal_id"), "evidence", ["goal_id"], unique=False)
    op.create_index(op.f("ix_evidence_submitted_by_user_id"), "evidence", ["submitted_by_user_id"], unique=False)
    op.create_index("ix_evidence_goal_id_created_at", "evidence", ["goal_id", "created_at"], unique=False)

    op.create_table(
        "arbitration_cases",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("goal_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_by_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("decision", arbitration_decision, nullable=False),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.CheckConstraint("reason <> ''", name=op.f("ck_arbitration_cases_arbitration_cases_reason_not_empty")),
        sa.CheckConstraint(
            "(decision = 'pending'::arbitration_decision AND resolved_at IS NULL) "
            "OR decision <> 'pending'::arbitration_decision",
            name=op.f("ck_arbitration_cases_arbitration_cases_pending_resolution"),
        ),
        sa.ForeignKeyConstraint(
            ["created_by_user_id"],
            ["users.id"],
            name=op.f("fk_arbitration_cases_created_by_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["goal_id"],
            ["goals.id"],
            name=op.f("fk_arbitration_cases_goal_id_goals"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_arbitration_cases")),
    )
    op.create_index(op.f("ix_arbitration_cases_goal_id"), "arbitration_cases", ["goal_id"], unique=False)
    op.create_index(
        "ix_arbitration_cases_decision_created_at",
        "arbitration_cases",
        ["decision", "created_at"],
        unique=False,
    )
    op.create_index(
        "ux_arbitration_cases_goal_id_pending",
        "arbitration_cases",
        ["goal_id"],
        unique=True,
        postgresql_where=sa.text("decision = 'pending'::arbitration_decision"),
    )

    op.create_table(
        "arbitration_assignments",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("assigned_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("has_voted", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.ForeignKeyConstraint(
            ["case_id"],
            ["arbitration_cases.id"],
            name=op.f("fk_arbitration_assignments_case_id_arbitration_cases"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_arbitration_assignments_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_arbitration_assignments")),
        sa.UniqueConstraint(
            "case_id",
            "user_id",
            name=op.f("uq_arbitration_assignments_case_id_user_id"),
        ),
    )
    op.create_index(op.f("ix_arbitration_assignments_case_id"), "arbitration_assignments", ["case_id"], unique=False)
    op.create_index(op.f("ix_arbitration_assignments_user_id"), "arbitration_assignments", ["user_id"], unique=False)
    op.create_index(
        "ix_arbitration_assignments_user_id_has_voted",
        "arbitration_assignments",
        ["user_id", "has_voted"],
        unique=False,
    )

    op.create_table(
        "arbitration_votes",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("voter_user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("decision", arbitration_decision, nullable=False),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.CheckConstraint(
            "decision IN ('approved'::arbitration_decision, 'rejected'::arbitration_decision)",
            name=op.f("ck_arbitration_votes_arbitration_votes_decision_resolved_only"),
        ),
        sa.ForeignKeyConstraint(
            ["case_id"],
            ["arbitration_cases.id"],
            name=op.f("fk_arbitration_votes_case_id_arbitration_cases"),
            ondelete="CASCADE",
        ),
        sa.ForeignKeyConstraint(
            ["voter_user_id"],
            ["users.id"],
            name=op.f("fk_arbitration_votes_voter_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_arbitration_votes")),
        sa.UniqueConstraint(
            "case_id",
            "voter_user_id",
            name=op.f("uq_arbitration_votes_case_id_voter_user_id"),
        ),
    )
    op.create_index(op.f("ix_arbitration_votes_case_id"), "arbitration_votes", ["case_id"], unique=False)
    op.create_index(op.f("ix_arbitration_votes_voter_user_id"), "arbitration_votes", ["voter_user_id"], unique=False)

    op.create_table(
        "evidence_files",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("evidence_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("type", evidence_attachment_type, nullable=False),
        sa.Column("storage_key", sa.Text(), nullable=False),
        sa.Column("url", sa.Text(), nullable=False),
        sa.Column("mime_type", sa.Text(), nullable=True),
        sa.Column("file_name", sa.Text(), nullable=True),
        sa.Column("file_size_bytes", sa.BigInteger(), nullable=True),
        sa.CheckConstraint(
            "file_size_bytes IS NULL OR file_size_bytes >= 0",
            name=op.f("ck_evidence_files_evidence_files_size_non_negative"),
        ),
        sa.ForeignKeyConstraint(
            ["evidence_id"],
            ["evidence.id"],
            name=op.f("fk_evidence_files_evidence_id_evidence"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_evidence_files")),
    )
    op.create_index(op.f("ix_evidence_files_evidence_id"), "evidence_files", ["evidence_id"], unique=False)

    op.create_table(
        "wallet_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("type", wallet_transaction_type, nullable=False),
        sa.Column("amount", sa.Numeric(14, 2), nullable=False),
        sa.Column("balance_before", sa.Numeric(14, 2), nullable=False),
        sa.Column("balance_after", sa.Numeric(14, 2), nullable=False),
        sa.Column("goal_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("bet_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("arbitration_case_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("reference_key", sa.Text(), nullable=True),
        sa.CheckConstraint(
            "balance_after >= 0",
            name=op.f("ck_wallet_transactions_wallet_transactions_balance_after_non_negative"),
        ),
        sa.ForeignKeyConstraint(
            ["arbitration_case_id"],
            ["arbitration_cases.id"],
            name=op.f("fk_wallet_transactions_arbitration_case_id_arbitration_cases"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["bet_id"],
            ["bets.id"],
            name=op.f("fk_wallet_transactions_bet_id_bets"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["goal_id"],
            ["goals.id"],
            name=op.f("fk_wallet_transactions_goal_id_goals"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_wallet_transactions_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_wallet_transactions")),
        sa.UniqueConstraint("reference_key", name=op.f("uq_wallet_transactions_reference_key")),
    )
    op.create_index(op.f("ix_wallet_transactions_user_id"), "wallet_transactions", ["user_id"], unique=False)
    op.create_index(op.f("ix_wallet_transactions_goal_id"), "wallet_transactions", ["goal_id"], unique=False)
    op.create_index(
        "ix_wallet_transactions_user_id_created_at",
        "wallet_transactions",
        ["user_id", "created_at"],
        unique=False,
    )

    op.create_table(
        "rating_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reason", rating_transaction_reason, nullable=False),
        sa.Column("delta", sa.Integer(), nullable=False),
        sa.Column("rating_before", sa.Integer(), nullable=False),
        sa.Column("rating_after", sa.Integer(), nullable=False),
        sa.Column("goal_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("bet_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("arbitration_case_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.CheckConstraint(
            "rating_after >= 0",
            name=op.f("ck_rating_transactions_rating_transactions_rating_after_non_negative"),
        ),
        sa.ForeignKeyConstraint(
            ["arbitration_case_id"],
            ["arbitration_cases.id"],
            name=op.f("fk_rating_transactions_arbitration_case_id_arbitration_cases"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["bet_id"],
            ["bets.id"],
            name=op.f("fk_rating_transactions_bet_id_bets"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["goal_id"],
            ["goals.id"],
            name=op.f("fk_rating_transactions_goal_id_goals"),
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_rating_transactions_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_rating_transactions")),
    )
    op.create_index(op.f("ix_rating_transactions_user_id"), "rating_transactions", ["user_id"], unique=False)
    op.create_index(op.f("ix_rating_transactions_goal_id"), "rating_transactions", ["goal_id"], unique=False)
    op.create_index(
        "ix_rating_transactions_user_id_created_at",
        "rating_transactions",
        ["user_id", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""
    bind = op.get_bind()

    op.drop_index("ix_rating_transactions_user_id_created_at", table_name="rating_transactions")
    op.drop_index(op.f("ix_rating_transactions_goal_id"), table_name="rating_transactions")
    op.drop_index(op.f("ix_rating_transactions_user_id"), table_name="rating_transactions")
    op.drop_table("rating_transactions")

    op.drop_index("ix_wallet_transactions_user_id_created_at", table_name="wallet_transactions")
    op.drop_index(op.f("ix_wallet_transactions_goal_id"), table_name="wallet_transactions")
    op.drop_index(op.f("ix_wallet_transactions_user_id"), table_name="wallet_transactions")
    op.drop_table("wallet_transactions")

    op.drop_index(op.f("ix_evidence_files_evidence_id"), table_name="evidence_files")
    op.drop_table("evidence_files")

    op.drop_index(op.f("ix_arbitration_votes_voter_user_id"), table_name="arbitration_votes")
    op.drop_index(op.f("ix_arbitration_votes_case_id"), table_name="arbitration_votes")
    op.drop_table("arbitration_votes")

    op.drop_index("ix_arbitration_assignments_user_id_has_voted", table_name="arbitration_assignments")
    op.drop_index(op.f("ix_arbitration_assignments_user_id"), table_name="arbitration_assignments")
    op.drop_index(op.f("ix_arbitration_assignments_case_id"), table_name="arbitration_assignments")
    op.drop_table("arbitration_assignments")

    op.drop_index("ux_arbitration_cases_goal_id_pending", table_name="arbitration_cases")
    op.drop_index("ix_arbitration_cases_decision_created_at", table_name="arbitration_cases")
    op.drop_index(op.f("ix_arbitration_cases_goal_id"), table_name="arbitration_cases")
    op.drop_table("arbitration_cases")

    op.drop_index("ix_evidence_goal_id_created_at", table_name="evidence")
    op.drop_index(op.f("ix_evidence_submitted_by_user_id"), table_name="evidence")
    op.drop_index(op.f("ix_evidence_goal_id"), table_name="evidence")
    op.drop_table("evidence")

    op.drop_index("ix_bets_goal_id_created_at", table_name="bets")
    op.drop_index("ix_bets_goal_id_side", table_name="bets")
    op.drop_index(op.f("ix_bets_user_id"), table_name="bets")
    op.drop_index(op.f("ix_bets_goal_id"), table_name="bets")
    op.drop_table("bets")

    op.drop_index("ix_goals_user_id_created_at", table_name="goals")
    op.drop_index("ix_goals_created_at", table_name="goals")
    op.drop_index("ix_goals_status_deadline_at", table_name="goals")
    op.drop_index(op.f("ix_goals_user_id"), table_name="goals")
    op.drop_table("goals")

    op.drop_index(op.f("ix_users_email"), table_name="users")
    op.drop_table("users")

    rating_transaction_reason.drop(bind, checkfirst=True)
    wallet_transaction_type.drop(bind, checkfirst=True)
    arbitration_decision.drop(bind, checkfirst=True)
    evidence_attachment_type.drop(bind, checkfirst=True)
    bet_source.drop(bind, checkfirst=True)
    bet_side.drop(bind, checkfirst=True)
    goal_status.drop(bind, checkfirst=True)
