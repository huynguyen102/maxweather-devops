# ADR 0006 — Single region, multi-AZ; region-level DR deferred

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
Requirement #1 asks for high availability and 24/7 operation. The platform is deployed in one AWS region across two Availability Zones. This survives the loss of a pod, a node, or a whole AZ. It does **not** survive the loss of the entire region. The question is whether to build multi-region disaster recovery (DR).

HA (staying up through component/AZ failure within a region) and DR (surviving the loss of a region) are different problems with very different cost and complexity.

## Decision
Run a **single region, multi-AZ**. Region-level DR is **deferred** — considered and deliberately not built for this assessment.

Multi-AZ satisfies the HA/24-7 requirement. Multi-region DR is not in the brief and is a large jump in cost and complexity (duplicate infrastructure, cross-region data/image replication, multi-region identity, DNS failover, RTO/RPO targets).

## Alternatives considered
- **Active-active multi-region** — highest availability, highest cost/complexity; unjustified at this scope.
- **Active-passive with Route53 failover** — a standby region behind health-checked DNS failover; still doubles infra and adds identity/replication work.

## Consequences
- Positive: meets HA/24-7 at single-region cost; blast radius is understood and documented.
- Negative / trade-offs: a full-region outage is a full outage. A single cluster also means staging and prod share fate at the cluster level (see [ADR-0004](0004-single-cluster-two-namespaces.md)).
- The design is **DR-ready** cheaply, which is the mitigation: the app is stateless with no datastore (no cross-region data replication problem), and the Terraform is parameterized by `region`. Standing up a second region would be: `terraform apply` with another `region`, Route53 health-check failover across the two API Gateway endpoints, a second Cognito pool (Cognito is regional), ECR cross-region replication, and defined RTO/RPO targets.
