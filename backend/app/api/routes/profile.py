from fastapi import APIRouter, Depends

from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.user import CurrentUserProfile
from app.services.read_models import get_current_user_profile

router = APIRouter(tags=["profile"])


@router.get("/me", response_model=CurrentUserProfile)
def get_my_profile(current_user: User = Depends(get_current_user)) -> CurrentUserProfile:
    return get_current_user_profile(current_user)
