from uuid import UUID

from fastapi import APIRouter, Body, Depends, HTTPException, Request, Response, status
from pydantic import ValidationError

from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.evidence import (
    CreateEvidenceUploadRequest,
    CreateEvidenceUploadResponse,
)
from app.services.evidence import create_evidence_upload, upload_evidence_file

router = APIRouter(tags=["evidence"])


@router.post("/uploads", response_model=CreateEvidenceUploadResponse, status_code=status.HTTP_201_CREATED)
def create_upload_slot(
    request: Request,
    payload: dict = Body(...),
    current_user: User = Depends(get_current_user),
) -> CreateEvidenceUploadResponse:
    try:
        upload_request = CreateEvidenceUploadRequest.model_validate(payload)
    except ValidationError as exc:
        detail = "; ".join(error["msg"] for error in exc.errors()) or "Invalid request payload."
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=detail) from exc

    return create_evidence_upload(
        base_url=str(request.base_url).rstrip("/"),
        current_user_id=current_user.id,
        payload=upload_request,
    )


@router.put("/uploads/{upload_id}/content", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def upload_content(
    upload_id: UUID,
    request: Request,
    current_user: User = Depends(get_current_user),
) -> Response:
    content = await request.body()
    upload_evidence_file(
        upload_id=upload_id,
        current_user_id=current_user.id,
        content=content,
        content_type=request.headers.get("content-type"),
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
