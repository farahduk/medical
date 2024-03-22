import os
from typing import Optional


class AppConfig:
    ENV: Optional[str] = None

    DEBUG: bool = False
    VERSION: str = os.getenv("APP_VERSION", "001.dev")


class CeleryConfig:
    broker_url = os.getenv("CELERY_BROKER_URL")
    result_backend = os.getenv("CELERY_RESULT_BACKEND")
    result_extended = True

class Local(AppConfig):
    ENV = "development"

    DEBUG = True
