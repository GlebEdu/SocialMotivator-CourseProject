from typing import Optional
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.security import JWTError, decode_token
from app.db.session import get_db
from app.models.user import User

bearer_scheme = HTTPBearer(
    bearerFormat="JWT",
    description="Paste the access token returned by /api/v1/auth/login or /api/v1/auth/register.",
)


def get_current_user(
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if credentials.scheme.lower() != "bearer":
        raise credentials_exception

    try:
        payload = decode_token(credentials.credentials)
    except JWTError as exc:
        raise credentials_exception from exc

    if payload.get("type") != "access":
        raise credentials_exception

    subject = payload.get("sub")
    if not subject:
        raise credentials_exception

    try:
        user_id = UUID(subject)
    except ValueError as exc:
        raise credentials_exception from exc

    user: Optional[User] = db.get(User, user_id)
    if user is None or not user.is_active:
        raise credentials_exception

    return user
