# ADR 0005 — Open-Meteo as the weather data source

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
Assumption #1 states the backend need not be implemented — the app may connect to any public API. We want the demo to be self-contained and to avoid committing secrets to the repository.

## Decision
Use **Open-Meteo** as the upstream weather API. It is free and requires **no API key**.

## Alternatives considered
- **OpenWeatherMap / Google APIs** — require an API key, which means secret handling and a signup dependency for anyone reproducing the demo.

## Consequences
- Positive: fully self-contained demo; no secrets in the repo, consistent with the no-secrets guardrail.
- Negative / trade-offs: subject to Open-Meteo public rate limits.
- Mitigation: acceptable for demo traffic; the upstream URL is a Terraform/env variable, so swapping providers later is a one-line change.
