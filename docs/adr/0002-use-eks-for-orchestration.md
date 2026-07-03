# ADR 0002 — Use EKS as the container orchestration platform

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
The assessment mandates Kubernetes as the orchestration platform, with high availability, fault tolerance, and production-readiness. A real AWS account is available, so free-tier workarounds are not a constraint.

## Decision
Use **Amazon EKS** with an AWS-managed control plane and a **managed node group spread across 2 Availability Zones**.

## Alternatives considered
- **Self-managed Kubernetes / k3s on EC2** — cheaper, but shifts control-plane HA and upgrades onto us; not "production-ready" for this brief.
- **ECS/Fargate** — not Kubernetes; fails the explicit requirement.

## Consequences
- Positive: HA control plane managed by AWS; native integration with IAM/OIDC, CloudWatch, and the AWS Load Balancer / NLB; mirrors real production.
- Negative / trade-offs: EKS control plane and nodes incur hourly cost.
- Mitigation: deploy → capture evidence → `terraform destroy`.
