import datetime
import os
from celery.result import AsyncResult
from http import HTTPStatus as status_code

from quart import Quart, request, render_template, Blueprint

from .tasks import search_term

CONFIG: str = os.getenv("CONFIG", "medical.config.Local")

app = Quart(__name__)
app.config.from_object(CONFIG)


blueprint = Blueprint('medical', __name__)


@app.route('/')
async def index():
    return await render_template('index.html', hello='world')


@app.route("/search/", methods=["GET"])
async def search():

    term = request.args.get("term")
    if not term:
        return {}, status_code.OK
    task_id = search_term.delay(
        term=term, created_time=datetime.datetime.now())
    return {
        "records": "Available when the task is completed",
        "query": term,
        "task_id": task_id.id,

    }, status_code.OK


@app.route("/fetch/<string:task_id>", methods=["GET"])
async def fetch(task_id: str):
    t = AsyncResult(task_id)
    # if not complete
    output = {
        "task_id": task_id,
        "status": "processing",
        # "created_time": t.kwargs.get("created_time"),
    }
    # if complete
    if t.status == "SUCCESS":
        output = {
            "task_id": task_id,
            "status": "completed",
            "result": {
                "pmids": t.result.get("response", {}).get("esearchresult", {}).get("idlist", []),
                "records": t.result.get("response", {}).get("esearchresult", {}).get("count", 0),
            },
            "created_time": t.kwargs.get("created_time"),
            "run_seconds": t.result.get("run_seconds"),
        }
    return output, status_code.OK
