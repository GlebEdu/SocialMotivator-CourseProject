from fastapi import APIRouter

from app.schemas.health import HealthCheck

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthCheck, summary="Service healthcheck")
def healthcheck() -> HealthCheck:
    return HealthCheck()
