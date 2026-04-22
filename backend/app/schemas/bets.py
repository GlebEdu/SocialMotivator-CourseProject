from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import Field

from app.models.enums import BetSide
from app.schemas.base import CamelModel
from app.schemas.read_models import GoalBetSummaryDto


class PlaceBetRequest(CamelModel):
    side: BetSide
    amount: Decimal = Field(gt=0)


class BetDto(CamelModel):
    id: UUID
    goal_id: UUID
    user_id: UUID
    side: BetSide
    amount: float
    created_at: datetime


class PlaceBetResponse(CamelModel):
    bet: BetDto
    updated_bet_summary: GoalBetSummaryDto
    updated_balance: float
