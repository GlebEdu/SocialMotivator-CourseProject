from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal
from enum import Enum
from typing import Optional
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import Select, case, func, select
from sqlalchemy.orm import Session

from app.models.bet import Bet
from app.models.enums import BetSide, GoalStatus
from app.models.evidence import Evidence, EvidenceFile
from app.models.goal import Goal
from app.models.user import User
from app.schemas.read_models import (
    AuthorProfileSummaryDto,
    EvidenceAttachmentDto,
    GoalAuthorDto,
    GoalAuthorSummaryDto,
    GoalBetSummaryDto,
    GoalDetailsDto,
    GoalListBetSummaryDto,
    GoalListItemDto,
    GoalSnapshotDto,
    GoalViewerContextDto,
    LatestEvidenceDto,
    PublicUserDto,
)
from app.schemas.user import CurrentUserProfile


DEFAULT_PAGE_SIZE = 50


class DiscoverGoalsFilter(str, Enum):
    ALL = "all"
    PREDICTED = "predicted"
    NEW = "new"


def get_current_user_profile(current_user: User) -> CurrentUserProfile:
    return CurrentUserProfile.model_validate(current_user)


def get_user_profile_summary(db: Session, user_id: UUID) -> AuthorProfileSummaryDto:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    goals = _get_user_goals(db, user_id)
    summary = _get_goal_stats_for_user(db, user)

    return AuthorProfileSummaryDto(
        **summary.model_dump(),
        goals=goals,
    )


def get_goal_author_summary(db: Session, user_id: UUID) -> GoalAuthorSummaryDto:
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found.",
        )

    return _get_goal_stats_for_user(db, user)


def get_latest_goal_evidence(
    db: Session,
    goal_id: UUID,
) -> Optional[LatestEvidenceDto]:
    return _get_latest_evidence(db, goal_id)


def get_my_goals(
    db: Session,
    viewer_id: UUID,
    goal_status: Optional[GoalStatus] = None,
    limit: int = DEFAULT_PAGE_SIZE,
) -> list[GoalListItemDto]:
    stmt, _ = _build_goal_list_stmt(viewer_id=viewer_id)
    stmt = stmt.where(Goal.user_id == viewer_id)
    if goal_status is not None:
        stmt = stmt.where(Goal.status == goal_status)

    rows = db.execute(stmt.limit(limit)).mappings().all()
    return [_build_goal_list_item(row, viewer_id=viewer_id) for row in rows]


def get_discover_goals(
    db: Session,
    viewer_id: UUID,
    filter_value: DiscoverGoalsFilter = DiscoverGoalsFilter.ALL,
    limit: int = DEFAULT_PAGE_SIZE,
) -> list[GoalListItemDto]:
    stmt, viewer_aggregate = _build_goal_list_stmt(viewer_id=viewer_id)
    stmt = stmt.where(Goal.user_id != viewer_id).where(Goal.status != GoalStatus.COMPLETED)

    if filter_value is DiscoverGoalsFilter.PREDICTED:
        stmt = stmt.where(func.coalesce(viewer_aggregate.c.viewer_bets_count, 0) > 0)
    elif filter_value is DiscoverGoalsFilter.NEW:
        stmt = (
            stmt.where(func.coalesce(viewer_aggregate.c.viewer_bets_count, 0) == 0)
            .where(Goal.status == GoalStatus.ACTIVE)
        )

    rows = db.execute(stmt.limit(limit)).mappings().all()
    return [_build_goal_list_item(row, viewer_id=viewer_id) for row in rows]


def get_goal_details(
    db: Session,
    goal_id: UUID,
    viewer_id: UUID,
) -> GoalDetailsDto:
    stmt, _ = _build_goal_list_stmt(viewer_id=viewer_id)
    stmt = stmt.where(Goal.id == goal_id).limit(1)
    row = db.execute(stmt).mappings().first()
    if row is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found.",
        )

    goal = GoalSnapshotDto(
        id=row["goal_id"],
        user_id=row["goal_user_id"],
        title=row["goal_title"],
        description=row["goal_description"],
        status=row["goal_status"],
        created_at=row["goal_created_at"],
        deadline=row["goal_deadline_at"],
    )
    author = db.get(User, row["author_id"])
    if author is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Author not found.",
        )
    author_summary = _get_goal_stats_for_user(db, author)

    viewer_context = _build_viewer_context(
        goal_user_id=row["goal_user_id"],
        goal_status=row["goal_status"],
        deadline=row["goal_deadline_at"],
        viewer_bets_count=row["viewer_bets_count"],
        viewer_id=viewer_id,
    )
    bet_summary = _build_goal_bet_summary(row)
    latest_evidence = _get_latest_evidence(db, goal_id)

    return GoalDetailsDto(
        goal=goal,
        author_summary=author_summary,
        bet_summary=bet_summary,
        viewer_context=viewer_context,
        latest_evidence=latest_evidence,
    )


def get_goal_bet_summary(
    db: Session,
    goal_id: UUID,
    viewer_id: UUID,
) -> GoalBetSummaryDto:
    stmt, _ = _build_goal_list_stmt(viewer_id=viewer_id)
    stmt = stmt.where(Goal.id == goal_id).limit(1)
    row = db.execute(stmt).mappings().first()
    if row is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found.",
        )

    return _build_goal_bet_summary(row)


def _build_goal_list_stmt(viewer_id: UUID) -> tuple[Select, object]:
    bet_aggregate = _build_goal_bet_aggregate_subquery()
    viewer_aggregate = _build_goal_viewer_bet_subquery(viewer_id)

    stmt = (
        select(
            Goal.id.label("goal_id"),
            Goal.user_id.label("goal_user_id"),
            Goal.title.label("goal_title"),
            Goal.description.label("goal_description"),
            Goal.status.label("goal_status"),
            Goal.created_at.label("goal_created_at"),
            Goal.deadline_at.label("goal_deadline_at"),
            User.id.label("author_id"),
            User.display_name.label("author_display_name"),
            User.avatar_url.label("author_avatar_url"),
            User.rating.label("author_rating"),
            func.coalesce(bet_aggregate.c.total_pool, Decimal("0")).label("total_pool"),
            func.coalesce(bet_aggregate.c.for_pool, Decimal("0")).label("for_pool"),
            func.coalesce(bet_aggregate.c.against_pool, Decimal("0")).label("against_pool"),
            func.coalesce(bet_aggregate.c.bets_count, 0).label("bets_count"),
            func.coalesce(viewer_aggregate.c.viewer_total, Decimal("0")).label("viewer_total"),
            func.coalesce(viewer_aggregate.c.viewer_for_total, Decimal("0")).label(
                "viewer_for_total"
            ),
            func.coalesce(viewer_aggregate.c.viewer_against_total, Decimal("0")).label(
                "viewer_against_total"
            ),
            func.coalesce(viewer_aggregate.c.viewer_bets_count, 0).label("viewer_bets_count"),
        )
        .join(User, User.id == Goal.user_id)
        .outerjoin(bet_aggregate, bet_aggregate.c.goal_id == Goal.id)
        .outerjoin(viewer_aggregate, viewer_aggregate.c.goal_id == Goal.id)
        .order_by(Goal.created_at.desc(), Goal.id.desc())
    )

    return stmt, viewer_aggregate


def _build_goal_bet_aggregate_subquery():
    return (
        select(
            Bet.goal_id.label("goal_id"),
            func.coalesce(func.sum(Bet.amount), Decimal("0")).label("total_pool"),
            func.coalesce(
                func.sum(case((Bet.side == BetSide.FOR_GOAL, Bet.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("for_pool"),
            func.coalesce(
                func.sum(
                    case((Bet.side == BetSide.AGAINST_GOAL, Bet.amount), else_=Decimal("0"))
                ),
                Decimal("0"),
            ).label("against_pool"),
            func.count(Bet.id).label("bets_count"),
        )
        .group_by(Bet.goal_id)
        .subquery()
    )


def _build_goal_viewer_bet_subquery(viewer_id: UUID):
    return (
        select(
            Bet.goal_id.label("goal_id"),
            func.coalesce(func.sum(Bet.amount), Decimal("0")).label("viewer_total"),
            func.coalesce(
                func.sum(case((Bet.side == BetSide.FOR_GOAL, Bet.amount), else_=Decimal("0"))),
                Decimal("0"),
            ).label("viewer_for_total"),
            func.coalesce(
                func.sum(
                    case((Bet.side == BetSide.AGAINST_GOAL, Bet.amount), else_=Decimal("0"))
                ),
                Decimal("0"),
            ).label("viewer_against_total"),
            func.count(Bet.id).label("viewer_bets_count"),
        )
        .where(Bet.user_id == viewer_id)
        .group_by(Bet.goal_id)
        .subquery()
    )


def _get_goal_stats_for_user(db: Session, user: User) -> GoalAuthorSummaryDto:
    goals_stats = db.execute(
        select(
            func.count(Goal.id).label("total_goals"),
            func.coalesce(
                func.sum(case((Goal.status == GoalStatus.COMPLETED, 1), else_=0)),
                0,
            ).label("completed_goals"),
            func.coalesce(
                func.sum(case((Goal.status == GoalStatus.ACTIVE, 1), else_=0)),
                0,
            ).label("active_goals"),
            func.coalesce(
                func.sum(
                    case(
                        (
                            Goal.status.in_([GoalStatus.COMPLETED, GoalStatus.FAILED]),
                            1,
                        ),
                        else_=0,
                    )
                ),
                0,
            ).label("resolved_goals"),
        ).where(Goal.user_id == user.id)
    ).one()

    total_goals = int(goals_stats.total_goals or 0)
    completed_goals = int(goals_stats.completed_goals or 0)
    active_goals = int(goals_stats.active_goals or 0)
    resolved_goals = int(goals_stats.resolved_goals or 0)
    completion_rate = completed_goals / resolved_goals if resolved_goals else 0.0

    return GoalAuthorSummaryDto(
        user=PublicUserDto(
            id=user.id,
            display_name=user.display_name,
            avatar_url=user.avatar_url,
            rating=user.rating,
        ),
        total_goals=total_goals,
        completed_goals=completed_goals,
        active_goals=active_goals,
        resolved_goals=resolved_goals,
        completion_rate=completion_rate,
        completion_rate_label=_format_completion_rate_label(completion_rate, resolved_goals),
    )


def _get_user_goals(db: Session, user_id: UUID) -> list[GoalSnapshotDto]:
    goals = db.scalars(
        select(Goal)
        .where(Goal.user_id == user_id)
        .order_by(Goal.created_at.desc(), Goal.id.desc())
    ).all()

    return [
        GoalSnapshotDto(
            id=goal.id,
            user_id=goal.user_id,
            title=goal.title,
            description=goal.description,
            status=goal.status,
            created_at=goal.created_at,
            deadline=goal.deadline_at,
        )
        for goal in goals
    ]


def _get_latest_evidence(db: Session, goal_id: UUID) -> Optional[LatestEvidenceDto]:
    row = db.execute(
        select(
            Evidence.id.label("evidence_id"),
            Evidence.goal_id.label("goal_id"),
            Evidence.submitted_by_user_id.label("submitted_by_user_id"),
            Evidence.description.label("description"),
            Evidence.created_at.label("created_at"),
            EvidenceFile.id.label("attachment_id"),
            EvidenceFile.type.label("attachment_type"),
            EvidenceFile.url.label("attachment_url"),
            EvidenceFile.mime_type.label("attachment_mime_type"),
            EvidenceFile.file_name.label("attachment_file_name"),
        )
        .outerjoin(EvidenceFile, EvidenceFile.evidence_id == Evidence.id)
        .where(Evidence.goal_id == goal_id)
        .order_by(Evidence.created_at.desc(), Evidence.id.desc())
        .limit(1)
    ).mappings().first()

    if row is None:
        return None

    attachment = None
    if row["attachment_id"] is not None:
        attachment = EvidenceAttachmentDto(
            id=row["attachment_id"],
            type=row["attachment_type"],
            url=row["attachment_url"],
            mime_type=row["attachment_mime_type"],
            file_name=row["attachment_file_name"],
        )

    return LatestEvidenceDto(
        id=row["evidence_id"],
        goal_id=row["goal_id"],
        submitted_by_user_id=row["submitted_by_user_id"],
        description=row["description"],
        created_at=row["created_at"],
        attachment=attachment,
    )


def _build_goal_list_item(row, viewer_id: UUID) -> GoalListItemDto:
    return GoalListItemDto(
        id=row["goal_id"],
        title=row["goal_title"],
        description=row["goal_description"],
        status=row["goal_status"],
        created_at=row["goal_created_at"],
        deadline=row["goal_deadline_at"],
        author=GoalAuthorDto(
            id=row["author_id"],
            display_name=row["author_display_name"],
            rating=row["author_rating"],
        ),
        viewer_context=_build_viewer_context(
            goal_user_id=row["goal_user_id"],
            goal_status=row["goal_status"],
            deadline=row["goal_deadline_at"],
            viewer_bets_count=row["viewer_bets_count"],
            viewer_id=viewer_id,
        ),
        bet_summary=GoalListBetSummaryDto(
            total_pool=_as_float(row["total_pool"]),
            for_pool=_as_float(row["for_pool"]),
            against_pool=_as_float(row["against_pool"]),
            bets_count=int(row["bets_count"]),
        ),
    )


def _build_goal_bet_summary(row) -> GoalBetSummaryDto:
    viewer_for_total = _as_float(row["viewer_for_total"])
    viewer_against_total = _as_float(row["viewer_against_total"])
    viewer_total = _as_float(row["viewer_total"])
    viewer_has_bet = int(row["viewer_bets_count"] or 0) > 0

    return GoalBetSummaryDto(
        total_pool=_as_float(row["total_pool"]),
        for_pool=_as_float(row["for_pool"]),
        against_pool=_as_float(row["against_pool"]),
        bets_count=int(row["bets_count"]),
        viewer_total=viewer_total,
        viewer_for_total=viewer_for_total,
        viewer_against_total=viewer_against_total,
        viewer_has_bet=viewer_has_bet,
        viewer_only_for=viewer_for_total > 0 and viewer_against_total == 0,
        viewer_only_against=viewer_against_total > 0 and viewer_for_total == 0,
    )


def _build_viewer_context(
    goal_user_id: UUID,
    goal_status: GoalStatus,
    deadline: Optional[datetime],
    viewer_bets_count: int,
    viewer_id: UUID,
) -> GoalViewerContextDto:
    is_owner = goal_user_id == viewer_id
    deadline_allows_betting = not deadline_has_passed(deadline)
    has_prediction = int(viewer_bets_count or 0) > 0

    return GoalViewerContextDto(
        is_owner=is_owner,
        has_prediction=has_prediction,
        can_place_bet=not is_owner and goal_status == GoalStatus.ACTIVE and deadline_allows_betting,
        can_submit_evidence=is_owner and goal_status == GoalStatus.ACTIVE,
    )


def _format_completion_rate_label(completion_rate: float, resolved_goals: int) -> str:
    if resolved_goals == 0:
        return "No results yet"

    return f"{int((completion_rate * 100) + 0.5)}%"


def deadline_has_passed(
    deadline: Optional[datetime],
    *,
    now: Optional[datetime] = None,
) -> bool:
    if deadline is None:
        return False

    current_time = now or datetime.now(timezone.utc)
    deadline_end = deadline.replace(hour=23, minute=59, second=59, microsecond=999999)
    return current_time > deadline_end


def _as_float(value: Decimal | int | float | None) -> float:
    if value is None:
        return 0.0

    return float(value)
