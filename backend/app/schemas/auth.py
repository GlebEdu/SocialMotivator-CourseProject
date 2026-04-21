import re

from pydantic import BaseModel, Field, field_validator

from app.schemas.base import CamelModel
from app.schemas.user import CurrentUserProfile

EMAIL_PATTERN = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class RegisterRequest(CamelModel):
    display_name: str = Field(min_length=1, max_length=255)
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("email")
    @classmethod
    def validate_email(cls, value: str) -> str:
        normalized = value.strip().lower()
        if not EMAIL_PATTERN.match(normalized):
            raise ValueError("Invalid email format.")
        return normalized

    @field_validator("display_name")
    @classmethod
    def validate_display_name(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Display name must not be empty.")
        return value.strip()


class LoginRequest(CamelModel):
    email: str = Field(min_length=3, max_length=320)
    password: str = Field(min_length=1, max_length=128)

    @field_validator("email")
    @classmethod
    def validate_email(cls, value: str) -> str:
        normalized = value.strip().lower()
        if not EMAIL_PATTERN.match(normalized):
            raise ValueError("Invalid email format.")
        return normalized


class TokenPayload(BaseModel):
    sub: str
    type: str
    exp: int
    iat: int


class AuthResponse(CamelModel):
    access_token: str
    user: CurrentUserProfile
