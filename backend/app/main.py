from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.api.router import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.project_name,
    version=settings.app_version,
    debug=settings.debug,
)
media_dir = Path(settings.media_dir).resolve()
media_dir.mkdir(parents=True, exist_ok=True)
app.mount("/media", StaticFiles(directory=media_dir), name="media")
app.include_router(api_router, prefix=settings.api_v1_prefix)
