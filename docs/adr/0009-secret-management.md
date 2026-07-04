# ADR 0009 — Secret management

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
The platform currently needs **no application secrets**: the weather source is keyless (Open-Meteo, [ADR-0005](0005-open-meteo-weather-source.md)); the Lambda authorizer validates tokens using Cognito's **public** keys (JWKS); pods pull from ECR via the node IAM role. There are no `Secret` objects in the manifests — nothing sensitive to leak. The question is what to do **if** a runtime secret becomes necessary (e.g., switching to a keyed weather provider).

## Decision
Keep the app **secret-free and AWS-SDK-free** while it can be. If a runtime secret is required, store it in **AWS Secrets Manager** and consume it **pod-side**, not injected by the CI pipeline:
- **Preferred — External Secrets Operator (ESO)**: its controller assumes an IAM role via IRSA (the cluster OIDC provider we already use for the Cluster Autoscaler), reads Secrets Manager, and syncs it into a Kubernetes Secret. The app reads a normal env/file — it stays AWS-agnostic and portable.
- **Alternative — IRSA directly**: the app's ServiceAccount assumes a role with `secretsmanager:GetSecretValue`; the app reads Secrets Manager at startup. Simpler, but couples the app to the AWS SDK (breaks portability).

If Kubernetes Secrets are used at all, enable **EKS envelope encryption (KMS)** for Secrets.

## Alternatives considered
- **Plain Kubernetes Secret in etcd** — base64, no rotation, and (without KMS envelope encryption) weak at rest.
- **CI injects the secret at deploy** — the secret then lives in the CI system and in etcd, and only refreshes on redeploy (rotation lag).

## Consequences
- Today: zero secret surface — a security strength, not a gap.
- When needed: the documented path (SM + ESO/IRSA) keeps secrets out of the repo, out of CI, and rotatable, and preserves the app's portability. Not implemented now because the app has nothing to store (implementing it would mean inventing a secret the app does not need).
