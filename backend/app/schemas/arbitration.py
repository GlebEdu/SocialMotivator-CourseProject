from datetime import datetime
from typing import Optional
from uuid import UUID

from app.models.enums import ArbitrationDecision, GoalStatus
from app.schemas.base import CamelModel
from app.schemas.read_models import GoalAuthorSummaryDto, GoalSnapshotDto, LatestEvidenceDto


class ArbitrationViewerAssignmentDto(CamelModel):
    is_assigned: bool
    has_voted: bool


class ArbitrationViewerContextDto(CamelModel):
    is_assigned: bool
    has_voted: bool
    can_vote: bool


class ArbitrationAssignmentDto(CamelModel):
    user_id: UUID
    display_name: str
    has_voted: bool


class ArbitrationVoteDto(CamelModel):
    id: UUID
    case_id: UUID
    voter_user_id: UUID
    decision: ArbitrationDecision
    created_at: datetime
    comment: Optional[str] = None


class ArbitrationCaseDto(CamelModel):
    id: UUID
    goal_id: UUID
    created_by_user_id: UUID
    decision: ArbitrationDecision
    reason: str
    created_at: datetime
    resolved_at: Optional[datetime] = None


class ArbitrationCaseSummaryDto(CamelModel):
    id: UUID
    goal_id: UUID
    goal_title: str
    decision: ArbitrationDecision
    reason: str
    created_at: datetime
    resolved_at: Optional[datetime] = None
    viewer_assignment: ArbitrationViewerAssignmentDto


class ArbitrationCaseDetailsDto(CamelModel):
    case: ArbitrationCaseDto
    goal: GoalSnapshotDto
    author_summary: GoalAuthorSummaryDto
    latest_evidence: Optional[LatestEvidenceDto] = None
    assignments: list[ArbitrationAssignmentDto]
    votes: list[ArbitrationVoteDto]
    viewer_context: ArbitrationViewerContextDto


class SubmitArbitrationVoteRequest(CamelModel):
    decision: ArbitrationDecision
    comment: Optional[str] = None


class SubmitArbitrationVoteResponse(CamelModel):
    vote: ArbitrationVoteDto
    case_decision: ArbitrationDecision
    goal_status: GoalStatus
