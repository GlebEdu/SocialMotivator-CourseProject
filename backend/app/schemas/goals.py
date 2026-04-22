from datetime import date, datetime, time, timezone
from typing import Optional

from pydantic import Field, field_validator

from app.schemas.base import CamelModel
from app.schemas.bets import BetDto
from app.schemas.read_models import GoalSnapshotDto


class CreateGoalRequest(CamelModel):
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(min_length=1, max_length=5000)
    deadline: Optional[date] = None

    @field_validator("title")
    @classmethod
    def validate_title(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Title must not be empty.")
        return value.strip()

    @field_validator("description")
    @classmethod
    def validate_description(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Description must not be empty.")
        return value.strip()

    @field_validator("deadline")
    @classmethod
    def validate_deadline(cls, value: Optional[date]) -> Optional[date]:
        if value is None:
            return None

        today = datetime.now(timezone.utc).date()
        if value < today:
            raise ValueError("Deadline must not be in the past.")
        return value

    def deadline_at(self) -> Optional[datetime]:
        if self.deadline is None:
            return None
        return datetime.combine(self.deadline, time.min, tzinfo=timezone.utc)
class CreateGoalResponse(CamelModel):
    goal: GoalSnapshotDto
    author_auto_bet: BetDto
