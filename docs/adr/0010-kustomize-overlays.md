# ADR 0010 — Kustomize for staging/prod overlays

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
[ADR-0004](0004-single-cluster-two-namespaces.md) puts staging and prod in one cluster as two namespaces. The same app manifests must deploy to both, differing only in namespace, image tag, and sizing. We need that without copy-pasting YAML (which drifts).

## Decision
Use **Kustomize** — native to `kubectl` — with a **base** plus **staging/prod overlays**. The base holds the deliverable manifests (Deployment, Service, Ingress, HPA); each overlay sets the namespace, the ECR image, replicas, and the HPA envelope. Deploy with `kubectl apply -k overlays/<env>`.

## Alternatives considered
- **Duplicated plain YAML per environment** — simplest to read, but two copies drift out of sync.
- **Helm** — powerful templating, but heavier and out of scope for this assessment (no chart required); Kustomize covers the need natively.

## Consequences
- Positive: one base, no duplication; per-env differences are small, explicit overlays; the required raw manifests still live in `k8s/base/`.
- Negative / trade-offs: staging needed a distinct Ingress host so two catch-all Ingresses don't collide on one nginx controller (encoded in the staging overlay).
