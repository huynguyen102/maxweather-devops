# ADR 0003 — OAuth2 via Cognito issuer + custom Lambda authorizer

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
Requirement #4 requires OAuth2 to protect the APIs. Assumption #2 explicitly permits a custom Lambda authorizer, and assumption #5 makes API authorization mandatory. We want a legitimate OAuth2 story without expanding scope into a full identity platform.

## Decision
Use **Amazon Cognito** (user pool + resource server, `client_credentials` grant) as the OAuth2 token issuer, and an **API Gateway custom Lambda authorizer** that validates the Cognito-issued JWT (signature, `iss`, `aud`, expiry, scope).

## Alternatives considered
- **Pure custom JWT** (Lambda both issues and validates a self-signed token) — simplest, but not real OAuth2.
- **API Gateway native Cognito authorizer** — valid, but the brief specifically calls out a *custom Lambda authorizer*; keeping the Lambda satisfies the requirement and shows the authorization logic explicitly.

## Consequences
- Positive: standards-compliant OAuth2 with a real issuer; authorization logic is explicit and testable; token flow is demonstrable in Postman.
- Negative / trade-offs: adds a Cognito module and a Lambda authorizer module.
- Mitigation: both are small, single-purpose modules following the standard anatomy.
