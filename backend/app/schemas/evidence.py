from typing import Optional
from uuid import UUID

from pydantic import Field, field_validator, model_validator

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
    description: str = Field(default="", max_length=5000)
    attachment: Optional[SubmitEvidenceAttachmentRequest] = None
    attachments: list[SubmitEvidenceAttachmentRequest] = Field(
        default_factory=list,
        max_length=10,
    )

    @field_validator("description")
    @classmethod
    def validate_description(cls, value: str) -> str:
        return value.strip()

    @model_validator(mode="after")
    def validate_attachments(self) -> "SubmitEvidenceRequest":
        if not self.attachments and self.attachment is not None:
            self.attachments = [self.attachment]

        if not self.attachments:
            raise ValueError("At least one evidence attachment is required.")

        upload_ids = {attachment.upload_id for attachment in self.attachments}
        if len(upload_ids) != len(self.attachments):
            raise ValueError("Evidence attachments must be unique.")

        return self


class SubmitEvidenceResponse(CamelModel):
    evidence: LatestEvidenceDto
    goal_status: GoalStatus
    arbitration_case_id: UUID
