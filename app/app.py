"""Max Weather API — a thin, stateless proxy over the Open-Meteo forecast API.

Endpoints:
  GET /health              liveness/readiness probe for Kubernetes
  GET /forecast?lat=&lon=  current + daily forecast for a coordinate

The service holds no state, so it scales horizontally behind an HPA: any pod can
serve any request. All environment-specific values come from environment
variables, so the same image runs in any environment without a rebuild.
"""
import json
import logging
import os
import sys

import requests
from flask import Flask, jsonify, request

# --- configuration: parameterized via env, no hardcoded environment specifics ---
UPSTREAM_URL = os.environ.get("UPSTREAM_URL", "https://api.open-meteo.com/v1/forecast")
UPSTREAM_TIMEOUT = float(os.environ.get("UPSTREAM_TIMEOUT_SECONDS", "5"))
PORT = int(os.environ.get("PORT", "8080"))


# --- logging: one JSON line per event on stdout, so the log shipper (Fluent Bit
#     / Container Insights) can forward structured records to CloudWatch as-is ---
class JsonFormatter(logging.Formatter):
    def format(self, record):
        payload = {
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if isinstance(record.args, dict):
            payload.update(record.args)
        return json.dumps(payload)


_handler = logging.StreamHandler(sys.stdout)
_handler.setFormatter(JsonFormatter())
logging.basicConfig(level=logging.INFO, handlers=[_handler])
log = logging.getLogger("maxweather")

app = Flask(__name__)


@app.get("/health")
def health():
    # Cheap and dependency-free on purpose: the probe must not call upstream, or a
    # slow provider would fail pod liveness and trigger needless restarts.
    return jsonify(status="ok"), 200


@app.get("/forecast")
def forecast():
    lat = request.args.get("lat")
    lon = request.args.get("lon")
    if lat is None or lon is None:
        return jsonify(error="lat and lon query params are required"), 400
    try:
        lat_f, lon_f = float(lat), float(lon)
    except ValueError:
        return jsonify(error="lat and lon must be numbers"), 400

    params = {
        "latitude": lat_f,
        "longitude": lon_f,
        "current": "temperature_2m,weather_code,wind_speed_10m",
        "daily": "temperature_2m_max,temperature_2m_min",
        "timezone": "auto",
    }
    try:
        resp = requests.get(UPSTREAM_URL, params=params, timeout=UPSTREAM_TIMEOUT)
        resp.raise_for_status()
    except requests.RequestException as exc:
        log.error("upstream request failed", {"error": str(exc), "lat": lat_f, "lon": lon_f})
        return jsonify(error="weather provider unavailable"), 502

    data = resp.json()
    log.info("forecast served", {"lat": lat_f, "lon": lon_f})
    return jsonify(
        location={"lat": lat_f, "lon": lon_f},
        current=data.get("current"),
        daily=data.get("daily"),
        units={"current": data.get("current_units"), "daily": data.get("daily_units")},
    ), 200


if __name__ == "__main__":
    # Local dev only. In the container the app runs under gunicorn (see Dockerfile).
    app.run(host="0.0.0.0", port=PORT)
