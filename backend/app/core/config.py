from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    project_name: str = "HabitBet API"
    app_version: str = "0.1.0"
    api_v1_prefix: str = "/api/v1"
    database_url: str = "postgresql+psycopg://postgres:postgres@localhost:5432/habitbet"
    database_echo: bool = False
    jwt_secret: str = "change_me"
    jwt_alg: str = "HS256"
    jwt_access_token_expire_minutes: int = 60
    debug: bool = True
    media_dir: str = "media"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
