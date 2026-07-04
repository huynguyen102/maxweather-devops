# ADR 0007 — App CI/CD now; infra CI/CD + remote state as the next step

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
The assessment's deliverable #4 is a pipeline that deploys the **application** to the cluster — delivered as [jenkins/Jenkinsfile](../../jenkins/Jenkinsfile). Infrastructure (Terraform) is currently applied by an operator with **local state**. A dedicated infrastructure pipeline with **remote state** is good practice but is beyond the assessment's scope.

Three lifecycles exist, deliberately separated (see also [ADR-0001](0001-ai-assisted-workflow.md)):
- **infra** (Terraform) — changes rarely; provisions VPC/EKS/etc.
- **platform** (metrics-server, ingress-nginx, cluster-autoscaler) — bootstrapped once per cluster.
- **app** (Jenkins) — runs on every application change.

## Decision
Ship the **app CI/CD pipeline now**. **Defer** the infrastructure (Terraform) pipeline and the remote-state migration as a documented, designed next step — with a skeleton pipeline ([jenkins/Jenkinsfile.infra](../../jenkins/Jenkinsfile.infra)) and a backend example ([terraform/backend.tf.example](../../terraform/backend.tf.example)) provided so the path is concrete.

**Prerequisite for the infra pipeline (agreed): migrate local state → remote state = S3 backend + DynamoDB lock.** A pipeline (and a team) must share state and lock it so two runs cannot clobber each other.

**Infra pipeline shape:**
- Stages: `fmt -check` / `validate` → `tflint` + `tfsec` (IaC security) → `plan` (posted to the PR) → **manual approval** → `apply`.
- Triggers: PR → plan only; merge to `main` → plan → approval → apply. Path-filtered to `terraform/**`.
- Credentials: a dedicated least-privilege role assumed via OIDC — never a personal key.
- Two-phase seam (`api_backend_url` comes from the k8s NLB): either a follow-up "wire" job after the app/platform deploy, or a stable Route53 name so the infra run is self-contained (see ADR-0006).

## Alternatives considered
- **Build the infra pipeline now** — real scope creep for the assessment, and it forces the remote-state migration first; not justified before the required deliverables are done.
- **Say nothing** — loses the roadmap and the chance to show the design is understood.

## Consequences
- Positive: app deploys are automated and gated (staging → approval → prod); the infra pipeline is designed and skeletoned, so adopting it is a small, clear step.
- Negative / trade-offs: until adopted, infra changes are manual with local state — no shared state or locking, so it is safe only for a single operator. This is acceptable at the current scale and is the documented next thing to fix.
