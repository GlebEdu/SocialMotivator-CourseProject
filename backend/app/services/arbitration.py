from __future__ import annotations

from datetime import datetime, timezone
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.arbitration import ArbitrationAssignment, ArbitrationCase, ArbitrationVote
from app.models.bet import Bet
from app.models.enums import ArbitrationDecision, GoalStatus
from app.models.goal import Goal
from app.models.user import User
from app.schemas.arbitration import (
    ArbitrationAssignmentDto,
    ArbitrationCaseDetailsDto,
    ArbitrationCaseDto,
    ArbitrationCaseSummaryDto,
    ArbitrationViewerAssignmentDto,
    ArbitrationViewerContextDto,
    ArbitrationVoteDto,
    SubmitArbitrationVoteRequest,
    SubmitArbitrationVoteResponse,
)
from app.schemas.read_models import GoalSnapshotDto
from app.services.goal_resolution import resolve_goal
from app.services.read_models import get_goal_author_summary, get_latest_goal_evidence

ARBITRATION_MAJORITY_THRESHOLD = 2


def list_assigned_arbitration_cases(
    db: Session,
    *,
    current_user_id: UUID,
    decision: ArbitrationDecision | None = None,
    limit: int = 50,
) -> list[ArbitrationCaseSummaryDto]:
    stmt = (
        select(
            ArbitrationCase.id.label("case_id"),
            ArbitrationCase.goal_id.label("goal_id"),
            Goal.title.label("goal_title"),
            ArbitrationCase.decision.label("decision"),
            ArbitrationCase.reason.label("reason"),
            ArbitrationCase.created_at.label("created_at"),
            ArbitrationCase.resolved_at.label("resolved_at"),
            ArbitrationAssignment.has_voted.label("has_voted"),
        )
        .join(ArbitrationAssignment, ArbitrationAssignment.case_id == ArbitrationCase.id)
        .join(Goal, Goal.id == ArbitrationCase.goal_id)
        .where(ArbitrationAssignment.user_id == current_user_id)
        .order_by(ArbitrationCase.created_at.desc(), ArbitrationCase.id.desc())
        .limit(limit)
    )
    if decision is not None:
        stmt = stmt.where(ArbitrationCase.decision == decision)

    rows = db.execute(stmt).mappings().all()
    return [
        ArbitrationCaseSummaryDto(
            id=row["case_id"],
            goal_id=row["goal_id"],
            goal_title=row["goal_title"],
            decision=row["decision"],
            reason=row["reason"],
            created_at=row["created_at"],
            resolved_at=row["resolved_at"],
            viewer_assignment=ArbitrationViewerAssignmentDto(
                is_assigned=True,
                has_voted=bool(row["has_voted"]),
            ),
        )
        for row in rows
    ]


def get_arbitration_case_details(
    db: Session,
    *,
    case_id: UUID,
    current_user_id: UUID,
) -> ArbitrationCaseDetailsDto:
    arbitration_case = db.get(ArbitrationCase, case_id)
    if arbitration_case is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Arbitration case not found.",
        )

    viewer_assignment = _get_assignment(
        db,
        case_id=case_id,
        user_id=current_user_id,
    )
    if viewer_assignment is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only assigned arbitrators can view this case.",
        )

    goal = db.get(Goal, arbitration_case.goal_id)
    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found.",
        )

    assignments = db.execute(
        select(
            ArbitrationAssignment.user_id,
            User.display_name,
            ArbitrationAssignment.has_voted,
        )
        .join(User, User.id == ArbitrationAssignment.user_id)
        .where(ArbitrationAssignment.case_id == case_id)
        .order_by(ArbitrationAssignment.assigned_at.asc(), ArbitrationAssignment.id.asc())
    ).mappings().all()
    votes = db.scalars(
        select(ArbitrationVote)
        .where(ArbitrationVote.case_id == case_id)
        .order_by(ArbitrationVote.created_at.asc(), ArbitrationVote.id.asc())
    ).all()

    return ArbitrationCaseDetailsDto(
        case=ArbitrationCaseDto(
            id=arbitration_case.id,
            goal_id=arbitration_case.goal_id,
            created_by_user_id=arbitration_case.created_by_user_id,
            decision=arbitration_case.decision,
            reason=arbitration_case.reason,
            created_at=arbitration_case.created_at,
            resolved_at=arbitration_case.resolved_at,
        ),
        goal=GoalSnapshotDto(
            id=goal.id,
            user_id=goal.user_id,
            title=goal.title,
            description=goal.description,
            status=goal.status,
            created_at=goal.created_at,
            deadline=goal.deadline_at,
        ),
        author_summary=get_goal_author_summary(db, goal.user_id),
        latest_evidence=get_latest_goal_evidence(db, goal.id),
        assignments=[
            ArbitrationAssignmentDto(
                user_id=row["user_id"],
                display_name=row["display_name"],
                has_voted=bool(row["has_voted"]),
            )
            for row in assignments
        ],
        votes=[_build_vote_dto(vote) for vote in votes],
        viewer_context=ArbitrationViewerContextDto(
            is_assigned=True,
            has_voted=viewer_assignment.has_voted,
            can_vote=(
                arbitration_case.decision == ArbitrationDecision.PENDING
                and not viewer_assignment.has_voted
            ),
        ),
    )


def submit_arbitration_vote(
    db: Session,
    *,
    case_id: UUID,
    current_user_id: UUID,
    payload: SubmitArbitrationVoteRequest,
) -> SubmitArbitrationVoteResponse:
    try:
        arbitration_case = db.execute(
            select(ArbitrationCase)
            .where(ArbitrationCase.id == case_id)
            .with_for_update()
        ).scalar_one_or_none()
        if arbitration_case is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Arbitration case not found.",
            )

        assignment = db.execute(
            select(ArbitrationAssignment)
            .where(ArbitrationAssignment.case_id == case_id)
            .where(ArbitrationAssignment.user_id == current_user_id)
            .with_for_update()
        ).scalar_one_or_none()
        if assignment is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only assigned arbitrators can vote on this case.",
            )

        if arbitration_case.decision != ArbitrationDecision.PENDING:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Arbitration voting has already been closed for this case.",
            )

        if assignment.has_voted:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You have already voted on this case.",
            )

        existing_vote = db.execute(
            select(ArbitrationVote.id)
            .where(ArbitrationVote.case_id == case_id)
            .where(ArbitrationVote.voter_user_id == current_user_id)
            .limit(1)
        ).scalar_one_or_none()
        if existing_vote is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Duplicate votes are not allowed.",
            )

        if payload.decision == ArbitrationDecision.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Votes must be either approved or rejected.",
            )

        vote = ArbitrationVote(
            case_id=case_id,
            voter_user_id=current_user_id,
            decision=payload.decision,
            comment=payload.comment,
        )
        db.add(vote)
        assignment.has_voted = True
        db.flush()

        approved_votes, rejected_votes = _get_vote_counts(db, case_id)
        case_decision = ArbitrationDecision.PENDING
        goal_status = GoalStatus.IN_REVIEW

        if approved_votes >= ARBITRATION_MAJORITY_THRESHOLD:
            case_decision = ArbitrationDecision.APPROVED
        elif rejected_votes >= ARBITRATION_MAJORITY_THRESHOLD:
            case_decision = ArbitrationDecision.REJECTED

        if case_decision != ArbitrationDecision.PENDING:
            resolved_at = datetime.now(timezone.utc)
            arbitration_case.decision = case_decision
            arbitration_case.resolved_at = resolved_at

            goal = db.execute(
                select(Goal)
                .where(Goal.id == arbitration_case.goal_id)
                .with_for_update()
            ).scalar_one_or_none()
            if goal is None:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Goal not found.",
                )

            goal_status = _resolve_goal_from_arbitration(
                db,
                goal=goal,
                arbitration_case=arbitration_case,
                resolved_at=resolved_at,
            )

        db.commit()
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise

    return SubmitArbitrationVoteResponse(
        vote=_build_vote_dto(vote),
        case_decision=case_decision,
        goal_status=goal_status,
    )


def _get_vote_counts(db: Session, case_id: UUID) -> tuple[int, int]:
    counts = {
        row.decision: int(row.votes_count)
        for row in db.execute(
            select(
                ArbitrationVote.decision,
                func.count(ArbitrationVote.id).label("votes_count"),
            )
            .where(ArbitrationVote.case_id == case_id)
            .group_by(ArbitrationVote.decision)
        )
    }
    return (
        counts.get(ArbitrationDecision.APPROVED, 0),
        counts.get(ArbitrationDecision.REJECTED, 0),
    )


def _resolve_goal_from_arbitration(
    db: Session,
    *,
    goal: Goal,
    arbitration_case: ArbitrationCase,
    resolved_at: datetime,
) -> GoalStatus:
    goal_status = _goal_status_for_decision(arbitration_case.decision)
    return resolve_goal(
        db,
        goal=goal,
        status=goal_status,
        resolved_at=resolved_at,
        reason=f"Resolved by arbitration: {arbitration_case.decision.value}",
        arbitration_case=arbitration_case,
        reference_prefix=f"arbitration:{arbitration_case.id}",
    )


def _get_assignment(
    db: Session,
    *,
    case_id: UUID,
    user_id: UUID,
) -> ArbitrationAssignment | None:
    return db.execute(
        select(ArbitrationAssignment)
        .where(ArbitrationAssignment.case_id == case_id)
        .where(ArbitrationAssignment.user_id == user_id)
        .limit(1)
    ).scalar_one_or_none()


def _goal_status_for_decision(decision: ArbitrationDecision) -> GoalStatus:
    if decision == ArbitrationDecision.APPROVED:
        return GoalStatus.COMPLETED
    if decision == ArbitrationDecision.REJECTED:
        return GoalStatus.FAILED

    raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="Pending arbitration cannot resolve a goal.",
    )


def _build_vote_dto(vote: ArbitrationVote) -> ArbitrationVoteDto:
    return ArbitrationVoteDto(
        id=vote.id,
        case_id=vote.case_id,
        voter_user_id=vote.voter_user_id,
        decision=vote.decision,
        created_at=vote.created_at,
        comment=vote.comment,
    )
