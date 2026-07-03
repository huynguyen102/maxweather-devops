# Max Weather API (app)

Stateless Flask proxy over the Open-Meteo forecast API.

| Endpoint | Purpose |
|---|---|
| `GET /health` | liveness/readiness probe (no upstream call) |
| `GET /forecast?lat=&lon=` | current + daily forecast for a coordinate |

## Configuration (environment variables)
| Variable | Default | Purpose |
|---|---|---|
| `UPSTREAM_URL` | `https://api.open-meteo.com/v1/forecast` | weather provider |
| `UPSTREAM_TIMEOUT_SECONDS` | `5` | upstream request timeout |
| `PORT` | `8080` | dev-server port (the container serves on 8080 via gunicorn) |

## Build & run with Docker
```sh
docker build -t maxweather:local .
docker run --rm -p 8080:8080 maxweather:local
```

## Run without Docker
```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/gunicorn --bind 0.0.0.0:8080 app:app
```

## Test
```sh
curl -s localhost:8080/health                              # {"status":"ok"}
curl -s "localhost:8080/forecast?lat=10.82&lon=106.63"     # current + 7-day daily
curl -s "localhost:8080/forecast?lat=abc"                  # 400 — bad input
```
