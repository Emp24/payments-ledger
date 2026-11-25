from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Gateway settings, read from environment variables (prefix ``GATEWAY_``).

    When run natively, values are also read from a local ``.env`` file if present.
    Real environment variables (as set by docker compose) take precedence.
    """

    model_config = SettingsConfigDict(env_prefix="GATEWAY_", env_file=".env")

    app_name: str = "payments-ledger gateway"
    database_url: str = "postgresql+psycopg://gateway:gateway@localhost:5432/gateway"
    redis_url: str = "redis://localhost:6379/0"
    rabbitmq_url: str = "amqp://guest:guest@localhost:5672/"
    ledger_url: str = "http://localhost:8080"
    mock_bank_url: str = "http://localhost:8001"


settings = Settings()
