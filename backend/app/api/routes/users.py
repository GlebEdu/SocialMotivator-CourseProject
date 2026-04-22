from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.bets import BetDto
from app.schemas.read_models import AuthorProfileSummaryDto
from app.services.bets import get_current_user_bets
from app.services.read_models import get_user_profile_summary

router = APIRouter(tags=["users"])


@router.get("/me/bets", response_model=list[BetDto])
def list_my_bets(
    goal_id: UUID | None = Query(default=None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[BetDto]:
    return get_current_user_bets(
        db=db,
        current_user_id=current_user.id,
        goal_id=goal_id,
    )


@router.get("/{user_id}/profile-summary", response_model=AuthorProfileSummaryDto)
def get_profile_summary(
    user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> AuthorProfileSummaryDto:
    return get_user_profile_summary(db, user_id)
