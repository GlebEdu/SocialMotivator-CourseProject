from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg://postgres:postgres@localhost:5432/habitbet"
    jwt_secret: str = "change_me"
    jwt_alg: str = "HS256"
    debug: bool = True
    media_dir: str = "media"


settings = Settings()
