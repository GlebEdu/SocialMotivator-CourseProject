from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from uuid import UUID, uuid4

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.arbitration import ArbitrationAssignment, ArbitrationCase
from app.models.bet import Bet
from app.models.enums import ArbitrationDecision, GoalStatus
from app.models.evidence import Evidence, EvidenceFile
from app.models.goal import Goal
from app.models.user import User
from app.schemas.evidence import (
    CreateEvidenceUploadRequest,
    CreateEvidenceUploadResponse,
    SubmitEvidenceRequest,
    SubmitEvidenceResponse,
)
from app.schemas.read_models import EvidenceAttachmentDto, LatestEvidenceDto

ARBITRATOR_COUNT = 3


def create_evidence_upload(
    *,
    base_url: str,
    current_user_id: UUID,
    payload: CreateEvidenceUploadRequest,
) -> CreateEvidenceUploadResponse:
    upload_id = uuid4()
    file_name = _sanitize_file_name(payload.file_name)
    relative_path = Path("evidence") / str(upload_id) / file_name
    metadata = {
        "upload_id": str(upload_id),
        "user_id": str(current_user_id),
        "type": payload.type.value,
        "file_name": file_name,
        "mime_type": payload.mime_type,
        "relative_path": relative_path.as_posix(),
        "file_url": _join_url(base_url, f"/media/{relative_path.as_posix()}"),
        "uploaded": False,
        "consumed": False,
        "file_size_bytes": None,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    _write_upload_metadata(upload_id, metadata)

    return CreateEvidenceUploadResponse(
        upload_id=upload_id,
        upload_url=_join_url(
            base_url,
            f"/api/v1/evidence/uploads/{upload_id}/content",
        ),
        file_url=metadata["file_url"],
    )


def upload_evidence_file(
    *,
    upload_id: UUID,
    current_user_id: UUID,
    content: bytes,
    content_type: str | None,
) -> None:
    metadata = _read_upload_metadata(upload_id)
    _ensure_upload_owner(metadata, current_user_id)

    destination = _media_root() / metadata["relative_path"]
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(content)

    metadata["uploaded"] = True
    metadata["file_size_bytes"] = len(content)
    if content_type:
        metadata["mime_type"] = content_type
    metadata["uploaded_at"] = datetime.now(timezone.utc).isoformat()
    _write_upload_metadata(upload_id, metadata)


def submit_goal_evidence(
    *,
    db: Session,
    goal_id: UUID,
    current_user_id: UUID,
    payload: SubmitEvidenceRequest,
) -> SubmitEvidenceResponse:
    try:
        goal = db.get(Goal, goal_id)
        if goal is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Goal not found.",
            )

        if goal.user_id != current_user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the goal owner can submit evidence.",
            )

        if goal.status != GoalStatus.ACTIVE:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Goal cannot accept evidence in its current state.",
            )

        upload = _read_upload_metadata(payload.attachment.upload_id)
        _ensure_upload_owner(upload, current_user_id)
        _validate_upload_for_submission(upload, payload)

        evidence = Evidence(
            goal_id=goal.id,
            submitted_by_user_id=current_user_id,
            description=payload.description,
        )
        db.add(evidence)
        db.flush()

        evidence_file = EvidenceFile(
            evidence_id=evidence.id,
            type=payload.attachment.type,
            storage_key=upload["relative_path"],
            url=upload["file_url"],
            mime_type=upload.get("mime_type"),
            file_name=upload.get("file_name"),
            file_size_bytes=upload.get("file_size_bytes"),
        )
        db.add(evidence_file)
        db.flush()

        arbitration_case = _get_pending_arbitration_case(db, goal.id)
        if arbitration_case is None:
            arbitration_case = _create_arbitration_case(
                db=db,
                goal=goal,
                created_by_user_id=current_user_id,
                reason=payload.description,
            )

        goal.status = GoalStatus.IN_REVIEW
        db.commit()
    except HTTPException:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise

    _mark_upload_consumed(payload.attachment.upload_id)

    return SubmitEvidenceResponse(
        evidence=LatestEvidenceDto(
            id=evidence.id,
            goal_id=evidence.goal_id,
            submitted_by_user_id=evidence.submitted_by_user_id,
            description=evidence.description,
            created_at=evidence.created_at,
            attachment=EvidenceAttachmentDto(
                id=evidence_file.id,
                type=evidence_file.type,
                url=evidence_file.url,
                mime_type=evidence_file.mime_type,
                file_name=evidence_file.file_name,
            ),
        ),
        goal_status=goal.status,
        arbitration_case_id=arbitration_case.id,
    )


def _create_arbitration_case(
    *,
    db: Session,
    goal: Goal,
    created_by_user_id: UUID,
    reason: str,
) -> ArbitrationCase:
    excluded_user_ids = {goal.user_id}
    excluded_user_ids.update(
        db.scalars(select(Bet.user_id).where(Bet.goal_id == goal.id)).all()
    )

    users_stmt = select(User).where(User.is_active.is_(True))
    if excluded_user_ids:
        users_stmt = users_stmt.where(User.id.notin_(excluded_user_ids))
    arbitrators = db.scalars(
        users_stmt.order_by(User.created_at.asc(), User.id.asc()).limit(ARBITRATOR_COUNT)
    ).all()

    if len(arbitrators) < ARBITRATOR_COUNT:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not enough users are available to assign arbitrators.",
        )

    arbitration_case = ArbitrationCase(
        goal_id=goal.id,
        created_by_user_id=created_by_user_id,
        reason=reason,
        decision=ArbitrationDecision.PENDING,
    )
    db.add(arbitration_case)
    db.flush()

    for arbitrator in arbitrators:
        db.add(
            ArbitrationAssignment(
                case_id=arbitration_case.id,
                user_id=arbitrator.id,
            )
        )
    db.flush()

    return arbitration_case


def _get_pending_arbitration_case(db: Session, goal_id: UUID) -> ArbitrationCase | None:
    return db.execute(
        select(ArbitrationCase)
        .where(ArbitrationCase.goal_id == goal_id)
        .where(ArbitrationCase.decision == ArbitrationDecision.PENDING)
        .limit(1)
    ).scalar_one_or_none()


def _validate_upload_for_submission(
    upload: dict[str, Any],
    payload: SubmitEvidenceRequest,
) -> None:
    if upload.get("consumed"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Upload slot has already been used.",
        )

    if not upload.get("uploaded"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Upload content has not been received yet.",
        )

    if upload["type"] != payload.attachment.type.value:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Attachment type does not match the upload slot.",
        )

    if upload["file_name"] != _sanitize_file_name(payload.attachment.file_name):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Attachment file name does not match the upload slot.",
        )


def _ensure_upload_owner(upload: dict[str, Any], current_user_id: UUID) -> None:
    if upload["user_id"] != str(current_user_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Upload slot does not belong to the current user.",
        )


def _mark_upload_consumed(upload_id: UUID) -> None:
    metadata = _read_upload_metadata(upload_id)
    metadata["consumed"] = True
    metadata["consumed_at"] = datetime.now(timezone.utc).isoformat()
    _write_upload_metadata(upload_id, metadata)


def _read_upload_metadata(upload_id: UUID) -> dict[str, Any]:
    metadata_path = _upload_metadata_path(upload_id)
    if not metadata_path.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Evidence upload slot not found.",
        )

    return json.loads(metadata_path.read_text(encoding="utf-8"))


def _write_upload_metadata(upload_id: UUID, metadata: dict[str, Any]) -> None:
    metadata_path = _upload_metadata_path(upload_id)
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(json.dumps(metadata), encoding="utf-8")


def _upload_metadata_path(upload_id: UUID) -> Path:
    return _media_root() / "evidence_uploads" / f"{upload_id}.json"


def _media_root() -> Path:
    root = Path(settings.media_dir).resolve()
    root.mkdir(parents=True, exist_ok=True)
    return root


def _sanitize_file_name(value: str) -> str:
    name = Path(value).name.strip()
    return name or f"file-{uuid4()}"


def _join_url(base_url: str, path: str) -> str:
    return f"{base_url.rstrip('/')}/{path.lstrip('/')}"
