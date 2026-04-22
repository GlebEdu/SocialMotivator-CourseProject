from typing import Optional
from uuid import UUID

from pydantic import Field, field_validator

from app.models.enums import EvidenceAttachmentType, GoalStatus
from app.schemas.base import CamelModel
from app.schemas.read_models import LatestEvidenceDto


class CreateEvidenceUploadRequest(CamelModel):
    type: EvidenceAttachmentType
    file_name: str = Field(min_length=1, max_length=255)
    mime_type: Optional[str] = Field(default=None, max_length=255)

    @field_validator("file_name")
    @classmethod
    def validate_file_name(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("File name must not be empty.")
        return value.strip()


class CreateEvidenceUploadResponse(CamelModel):
    upload_id: UUID
    upload_url: str
    file_url: str


class SubmitEvidenceAttachmentRequest(CamelModel):
    type: EvidenceAttachmentType
    upload_id: UUID
    file_name: str = Field(min_length=1, max_length=255)
    mime_type: Optional[str] = Field(default=None, max_length=255)

    @field_validator("file_name")
    @classmethod
    def validate_file_name(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("File name must not be empty.")
        return value.strip()


class SubmitEvidenceRequest(CamelModel):
    description: str = Field(min_length=1, max_length=5000)
    attachment: SubmitEvidenceAttachmentRequest

    @field_validator("description")
    @classmethod
    def validate_description(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Description must not be empty.")
        return value.strip()


class SubmitEvidenceResponse(CamelModel):
    evidence: LatestEvidenceDto
    goal_status: GoalStatus
    arbitration_case_id: UUID
