import asyncio
import csv
import json
import os
import re
from pathlib import Path
from threading import Lock
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

load_dotenv(Path(__file__).parent.parent / ".env")

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
CSV_PATH = Path(__file__).parent.parent / "files" / "saved_packages.csv"
CSV_LOCK = Lock()

CSV_HEADERS = ["id", "date", "brand", "campaign", "channel", "name", "description", "rationale", "segments", "approx_size"]


def read_csv() -> dict:
    if not CSV_PATH.exists():
        return {}
    with open(CSV_PATH, newline="", encoding="utf-8") as f:
        return {row["id"]: row for row in csv.DictReader(f) if row.get("id")}


def write_csv(records: dict):
    with open(CSV_PATH, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=CSV_HEADERS)
        writer.writeheader()
        for rec in records.values():
            writer.writerow({h: rec.get(h, "") for h in CSV_HEADERS})


def record_to_storage_value(rec: dict) -> str:
    return json.dumps({
        "id": rec.get("id", ""),
        "date": rec.get("date", ""),
        "brand": rec.get("brand", ""),
        "campaign": rec.get("campaign", ""),
        "channel": rec.get("channel", ""),
        "name": rec.get("name", ""),
        "description": rec.get("description", ""),
        "rationale": rec.get("rationale", ""),
        "segments": [s for s in rec.get("segments", "").split(" | ") if s],
        "approx_size": rec.get("approx_size", ""),
    })


def storage_value_to_record(value_str: str) -> dict:
    data = json.loads(value_str)
    return {
        "id": data.get("id", ""),
        "date": data.get("date", ""),
        "brand": data.get("brand", ""),
        "campaign": data.get("campaign", ""),
        "channel": data.get("channel", ""),
        "name": data.get("name", ""),
        "description": data.get("description", ""),
        "rationale": data.get("rationale", ""),
        "segments": " | ".join(data.get("segments", [])),
        "approx_size": data.get("approx_size", ""),
    }


@asynccontextmanager
async def lifespan(app: FastAPI):
    CSV_PATH.parent.mkdir(exist_ok=True)
    if not CSV_PATH.exists():
        write_csv({})
    yield


app = FastAPI(lifespan=lifespan)


# ── Storage API ──────────────────────────────────────────────────────────────


@app.get("/api/storage")
def list_keys(prefix: str = ""):
    with CSV_LOCK:
        records = read_csv()
    return {"keys": [k for k in records if k.startswith(prefix)]}


@app.get("/api/storage/{key:path}")
def get_key(key: str):
    with CSV_LOCK:
        records = read_csv()
    rec = records.get(key)
    if rec is None:
        return JSONResponse({"value": None})
    return {"value": record_to_storage_value(rec)}


@app.post("/api/storage/{key:path}")
async def set_key(key: str, request: Request):
    body = await request.json()
    rec = storage_value_to_record(body.get("value", "{}"))
    if not rec["id"]:
        rec["id"] = key
    with CSV_LOCK:
        records = read_csv()
        records[key] = rec
        write_csv(records)
    return {"ok": True}


@app.delete("/api/storage/{key:path}")
def delete_key(key: str):
    with CSV_LOCK:
        records = read_csv()
        records.pop(key, None)
        write_csv(records)
    return {"ok": True}


# ── Anthropic proxy ──────────────────────────────────────────────────────────


@app.post("/api/claude/messages")
async def claude_messages(request: Request):
    if not ANTHROPIC_API_KEY:
        raise HTTPException(status_code=500, detail="ANTHROPIC_API_KEY not set")

    body = await request.body()

    async with httpx.AsyncClient(timeout=120) as client:
        resp = await client.post(
            "https://api.anthropic.com/v1/messages",
            content=body,
            headers={
                "Content-Type": "application/json",
                "x-api-key": ANTHROPIC_API_KEY,
                "anthropic-version": "2023-06-01",
            },
        )

    return JSONResponse(content=resp.json(), status_code=resp.status_code)


# ── SQL builds ───────────────────────────────────────────────────────────────

BUILDS_DIR = Path(__file__).parent.parent / "sql" / "builds"


@app.post("/api/sql/save")
async def save_sql(request: Request):
    body = await request.json()
    sql = body.get("sql", "")
    filename = body.get("filename", "")
    if not sql or not filename:
        raise HTTPException(status_code=400, detail="sql and filename required")
    filename = re.sub(r"[^a-zA-Z0-9_\-]", "", filename)
    if not filename.endswith(".sql"):
        filename += ".sql"
    BUILDS_DIR.mkdir(parents=True, exist_ok=True)
    (BUILDS_DIR / filename).write_text(sql, encoding="utf-8")
    return {"ok": True, "filename": filename}


# ── Snowflake ─────────────────────────────────────────────────────────────────


def _snowflake_execute(sql: str) -> list:
    import snowflake.connector  # imported here so missing install doesn't break startup
    conn = snowflake.connector.connect(
        account=os.environ.get("SNOWFLAKE_ACCOUNT", ""),
        user=os.environ.get("SNOWFLAKE_USER", ""),
        password=os.environ.get("SNOWFLAKE_PASSWORD", ""),
        database=os.environ.get("SNOWFLAKE_DATABASE", "PROXIMA"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", ""),
        role=os.environ.get("SNOWFLAKE_ROLE") or None,
    )
    try:
        cursors = conn.execute_string(sql, remove_comments=False)
        counts = []
        if cursors:
            try:
                rows = cursors[-1].fetchall()
                counts = [{"package": row[0], "size": row[1]} for row in rows]
            except Exception:
                pass
        return counts
    finally:
        conn.close()


@app.post("/api/snowflake/execute")
async def snowflake_execute(request: Request):
    required = ["SNOWFLAKE_ACCOUNT", "SNOWFLAKE_USER", "SNOWFLAKE_PASSWORD"]
    missing = [k for k in required if not os.environ.get(k)]
    if missing:
        raise HTTPException(status_code=503, detail=f"Snowflake not configured: {', '.join(missing)}")
    body = await request.json()
    sql = body.get("sql", "")
    loop = asyncio.get_event_loop()
    counts = await loop.run_in_executor(None, _snowflake_execute, sql)
    return {"ok": True, "counts": counts}


# ── Static files ─────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return RedirectResponse(url="/mosaic.html")

STATIC_DIR = Path(__file__).parent.parent / "frontend"
app.mount("/", StaticFiles(directory=STATIC_DIR, html=True), name="static")
