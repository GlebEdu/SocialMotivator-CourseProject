from typing import Optional
from uuid import UUID

from app.schemas.base import CamelModel


class CurrentUserProfile(CamelModel):
    id: UUID
    email: str
    display_name: str
    avatar_url: Optional[str] = None
    balance: float
    rating: int
