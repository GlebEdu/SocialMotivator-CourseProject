from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Body, Depends, HTTPException, Query, status
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.enums import GoalStatus
from app.models.user import User
from app.schemas.bets import PlaceBetRequest, PlaceBetResponse
from app.schemas.evidence import SubmitEvidenceRequest, SubmitEvidenceResponse
from app.schemas.goals import CreateGoalRequest, CreateGoalResponse
from app.schemas.read_models import GoalDetailsDto, GoalListItemDto
from app.services.bets import place_bet
from app.services.evidence import submit_goal_evidence
from app.services.goals import create_goal
from app.services.read_models import (
    DiscoverGoalsFilter,
    get_discover_goals,
    get_goal_details,
    get_my_goals,
)

router = APIRouter(tags=["goals"])


@router.post("", response_model=CreateGoalResponse, status_code=status.HTTP_201_CREATED)
def create_goal_endpoint(
    payload: dict = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> CreateGoalResponse:
    try:
        request = CreateGoalRequest.model_validate(payload)
    except ValidationError as exc:
        detail = "; ".join(error["msg"] for error in exc.errors()) or "Invalid request payload."
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail) from exc

    return create_goal(
        db=db,
        current_user_id=current_user.id,
        payload=request,
    )


@router.post(
    "/{goal_id}/bets",
    response_model=PlaceBetResponse,
    status_code=status.HTTP_201_CREATED,
)
def place_bet_endpoint(
    goal_id: UUID,
    payload: dict = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PlaceBetResponse:
    try:
        request = PlaceBetRequest.model_validate(payload)
    except ValidationError as exc:
        detail = "; ".join(error["msg"] for error in exc.errors()) or "Invalid request payload."
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail) from exc

    return place_bet(
        db=db,
        goal_id=goal_id,
        current_user_id=current_user.id,
        payload=request,
    )


@router.post(
    "/{goal_id}/evidence",
    response_model=SubmitEvidenceResponse,
    status_code=status.HTTP_201_CREATED,
)
def submit_evidence_endpoint(
    goal_id: UUID,
    payload: dict = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> SubmitEvidenceResponse:
    try:
        request = SubmitEvidenceRequest.model_validate(payload)
    except ValidationError as exc:
        detail = "; ".join(error["msg"] for error in exc.errors()) or "Invalid request payload."
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail) from exc

    return submit_goal_evidence(
        db=db,
        goal_id=goal_id,
        current_user_id=current_user.id,
        payload=request,
    )


@router.get("/mine", response_model=list[GoalListItemDto])
def list_my_goals(
    status: Optional[GoalStatus] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[GoalListItemDto]:
    return get_my_goals(
        db=db,
        viewer_id=current_user.id,
        goal_status=status,
        limit=limit,
    )


@router.get("/discover", response_model=list[GoalListItemDto])
def list_discover_goals(
    filter: DiscoverGoalsFilter = Query(default=DiscoverGoalsFilter.ALL),
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[GoalListItemDto]:
    return get_discover_goals(
        db=db,
        viewer_id=current_user.id,
        filter_value=filter,
        limit=limit,
    )


@router.get("/{goal_id}", response_model=GoalDetailsDto)
def get_goal(
    goal_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> GoalDetailsDto:
    return get_goal_details(
        db=db,
        goal_id=goal_id,
        viewer_id=current_user.id,
    )
