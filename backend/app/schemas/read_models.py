from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import Field

from app.models.enums import EvidenceAttachmentType, GoalStatus
from app.schemas.base import CamelModel


class GoalAuthorDto(CamelModel):
    id: UUID
    display_name: str
    rating: int


class PublicUserDto(CamelModel):
    id: UUID
    display_name: str
    avatar_url: Optional[str] = None
    rating: int


class GoalViewerContextDto(CamelModel):
    is_owner: bool
    has_prediction: bool
    can_place_bet: bool
    can_submit_evidence: bool


class GoalListBetSummaryDto(CamelModel):
    total_pool: float
    for_pool: float
    against_pool: float
    bets_count: int


class GoalBetSummaryDto(GoalListBetSummaryDto):
    viewer_total: float
    viewer_for_total: float
    viewer_against_total: float
    viewer_has_bet: bool
    viewer_only_for: bool
    viewer_only_against: bool


class GoalListItemDto(CamelModel):
    id: UUID
    title: str
    description: str
    status: GoalStatus
    created_at: datetime
    deadline: Optional[datetime] = None
    author: GoalAuthorDto
    viewer_context: GoalViewerContextDto
    bet_summary: GoalListBetSummaryDto


class GoalSnapshotDto(CamelModel):
    id: UUID
    user_id: UUID
    title: str
    description: str
    status: GoalStatus
    created_at: datetime
    deadline: Optional[datetime] = None


class GoalAuthorSummaryDto(CamelModel):
    user: PublicUserDto
    total_goals: int
    completed_goals: int
    active_goals: int
    resolved_goals: int
    completion_rate: float
    completion_rate_label: str


class AuthorProfileSummaryDto(GoalAuthorSummaryDto):
    goals: list[GoalSnapshotDto]


class EvidenceAttachmentDto(CamelModel):
    id: UUID
    type: EvidenceAttachmentType
    url: str
    mime_type: Optional[str] = None
    file_name: Optional[str] = None


class LatestEvidenceDto(CamelModel):
    id: UUID
    goal_id: UUID
    submitted_by_user_id: UUID
    description: str
    created_at: datetime
    attachment: Optional[EvidenceAttachmentDto] = None
    attachments: list[EvidenceAttachmentDto] = Field(default_factory=list)


class GoalDetailsDto(CamelModel):
    goal: GoalSnapshotDto
    author_summary: GoalAuthorSummaryDto
    bet_summary: GoalBetSummaryDto
    viewer_context: GoalViewerContextDto
    latest_evidence: Optional[LatestEvidenceDto] = None
