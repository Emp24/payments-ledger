from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Mock bank settings, read from environment variables (prefix ``MOCK_BANK_``)."""

    model_config = SettingsConfigDict(env_prefix="MOCK_BANK_")

    app_name: str = "payments-ledger mock bank"


settings = Settings()
