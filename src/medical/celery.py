from .config import CeleryConfig


def get_celery_app():
    from celery import Celery

    app_ = Celery("Medical")
    app_.config_from_object(CeleryConfig)

    # Load task modules
    app_.autodiscover_tasks(["medical"])

    return app_


celery = get_celery_app()

celery.conf.broker_transport_options = {"retry_policy": {"timeout": 5.0}}
