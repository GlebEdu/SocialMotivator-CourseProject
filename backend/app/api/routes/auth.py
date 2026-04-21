from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import AuthResponse, LoginRequest, RegisterRequest
from app.schemas.user import CurrentUserProfile
from app.services.auth import login_user, register_user

router = APIRouter(tags=["auth"])


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(
    payload: RegisterRequest,
    db: Session = Depends(get_db),
) -> AuthResponse:
    return register_user(db, payload)


@router.post("/login", response_model=AuthResponse)
def login(
    payload: LoginRequest,
    db: Session = Depends(get_db),
) -> AuthResponse:
    return login_user(db, payload)


@router.get("/me", response_model=CurrentUserProfile)
def me(current_user: User = Depends(get_current_user)) -> CurrentUserProfile:
    return CurrentUserProfile.model_validate(current_user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
def logout(current_user: User = Depends(get_current_user)) -> Response:
    return Response(status_code=status.HTTP_204_NO_CONTENT)
