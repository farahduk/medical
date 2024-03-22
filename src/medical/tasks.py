import os
import requests
import time
import datetime

from http import HTTPStatus as status_code

from .celery import celery

PUB_MED_URL: str = os.getenv("PUB_MED_URL", "")


@celery.task()
def search_term(term: str, created_time: datetime.datetime) -> dict:

    start_time = time.time()
    params = {"term": term}
    response = requests.get(PUB_MED_URL, params=params)
    end_time = time.time()
    duration = end_time - start_time
    if response.status_code == status_code.OK:
        return {"success": True, "response": response.json(), "run_seconds": duration}
    return {"success": False, "response": {}, "run_seconds": duration}
