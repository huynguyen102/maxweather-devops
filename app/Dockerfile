# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Run as a non-root user: a compromised process then has no privileged foothold.
RUN useradd --create-home --uid 10001 appuser
WORKDIR /app

# Install dependencies in their own layer so app-code changes don't reinstall them.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

USER appuser
EXPOSE 8080

# gunicorn is the production WSGI server (the Flask dev server is single-threaded
# and not for production). The container listens on 8080 — the port the k8s
# Service and Ingress target.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "app:app"]
