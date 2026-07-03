# ADR 0004 — Single EKS cluster, staging + prod namespaces

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
Requirement #5 asks for a CI/CD process that deploys to production only after successful testing in staging. This needs two environments, but standing up two full clusters would double the infrastructure and cost for an assessment.

## Decision
Run **one EKS cluster** with two Kubernetes **namespaces: `staging` and `prod`**. The Jenkins pipeline deploys to `staging`, runs verification, waits for manual approval, then deploys to `prod`.

## Alternatives considered
- **Two separate clusters** — strongest isolation, but ~2x cost and provisioning time; unjustified at this scope.
- **Single namespace** — no staging gate; fails requirement #5.

## Consequences
- Positive: full staging → approval → prod CI/CD story at roughly half the infra cost.
- Negative / trade-offs: weaker isolation than separate clusters (shared control plane and nodes).
- Mitigation: namespace-scoped resource quotas and RBAC; trade-off documented here as acceptable for the assessment scope.
