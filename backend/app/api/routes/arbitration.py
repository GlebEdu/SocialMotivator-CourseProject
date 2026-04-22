from uuid import UUID

from fastapi import APIRouter, Body, Depends, HTTPException, Query, status
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.enums import ArbitrationDecision
from app.models.user import User
from app.schemas.arbitration import (
    ArbitrationCaseDetailsDto,
    ArbitrationCaseSummaryDto,
    SubmitArbitrationVoteRequest,
    SubmitArbitrationVoteResponse,
)
from app.services.arbitration import (
    get_arbitration_case_details,
    list_assigned_arbitration_cases,
    submit_arbitration_vote,
)

router = APIRouter(tags=["arbitration"])


@router.get("/cases", response_model=list[ArbitrationCaseSummaryDto])
def list_cases(
    status_filter: ArbitrationDecision | None = Query(default=None, alias="status"),
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[ArbitrationCaseSummaryDto]:
    return list_assigned_arbitration_cases(
        db,
        current_user_id=current_user.id,
        decision=status_filter,
        limit=limit,
    )


@router.get("/cases/{case_id}", response_model=ArbitrationCaseDetailsDto)
def get_case(
    case_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ArbitrationCaseDetailsDto:
    return get_arbitration_case_details(
        db,
        case_id=case_id,
        current_user_id=current_user.id,
    )


@router.post(
    "/cases/{case_id}/votes",
    response_model=SubmitArbitrationVoteResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_vote(
    case_id: UUID,
    payload: dict = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> SubmitArbitrationVoteResponse:
    try:
        request = SubmitArbitrationVoteRequest.model_validate(payload)
    except ValidationError as exc:
        detail = "; ".join(error["msg"] for error in exc.errors()) or "Invalid request payload."
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail) from exc

    return submit_arbitration_vote(
        db,
        case_id=case_id,
        current_user_id=current_user.id,
        payload=request,
    )
