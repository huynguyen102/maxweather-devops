# Traceability — requirements & deliverables

Every requirement and deliverable from the brief, mapped to **how** it is met, **where** it lives, and the **evidence** it works. Live evidence is in [evidence.md](evidence.md).

## Requirements (7)

| # | Requirement | How it is met | Where | Evidence |
|---|---|---|---|---|
| 1 | Run 24/7, high availability | VPC + managed node group across 2 AZs; multi-AZ NLB; Deployment with ≥2 replicas | `terraform/modules/vpc`, `terraform/modules/eks`, `k8s/base/deployment.yaml` | 2 prod pods on 2 nodes/AZs |
| 2 | Scale with traffic | HPA (pods) + Cluster Autoscaler (nodes) + metrics-server | `k8s/base/hpa.yaml`, `k8s/platform/cluster-autoscaler.yaml`, `terraform/modules/eks` | HPA scaled 2→10 under load |
| 3 | Expose forecast as APIs | API Gateway HTTP API with proxy integration | `terraform/modules/api-gateway`, `app/` | newman authorized call → 200 |
| 4 | OAuth2-protected APIs | Cognito issuer (client_credentials) + custom Lambda authorizer | `terraform/modules/cognito`, `terraform/modules/lambda-authorizer`, `terraform/modules/api-gateway` | newman: token 200, no-token 401 |
| 5 | CI/CD deploy to prod after staging | Jenkins pipeline: build → ECR → staging → manual approval → prod | `jenkins/Jenkinsfile` | full pipeline ran green, approval gate |
| 6 | Application logs to CloudWatch | App logs JSON to stdout; Fluent Bit (observability addon) ships to CloudWatch | `terraform/modules/cloudwatch`, `app/app.py` | structured logs in Container Insights |
| 7 | Terraform, parameterized | 7 modules + root variables/tfvars; region & environment parameterized | `terraform/` | re-provisioned live 3× |

## Deliverables (6)

| # | Deliverable | Where | Status |
|---|---|---|---|
| 1 | Architecture diagram | `docs/architecture.md` (Mermaid) | done |
| 2 | Modular, tested Terraform | `terraform/modules/*` (+ `terraform-docs` READMEs) | done — `validate` + applied live |
| 3 | K8s: Deployment, Service, Nginx Ingress Controller, Ingress | `k8s/base/` (+ overlays), `k8s/platform/` | done (+ HPA) |
| 4 | Jenkins pipeline | `jenkins/Jenkinsfile` | done — validated + ran live |
| 5 | App API in API Gateway | `terraform/modules/api-gateway` | done — proven live |
| 6 | Postman with authentication | `postman/` | done — newman 5/5 |

## Beyond the brief (hardening & automation)
| Area | What | Where | ADR |
|---|---|---|---|
| Remote state | S3 (encrypted, versioned) + DynamoDB lock | `terraform/bootstrap`, `terraform/backend.tf` | [0008](adr/0008-remote-state-and-oidc-cicd.md) |
| OIDC CI/CD | GitHub Actions assumes an AWS role via OIDC (no static keys) | `.github/workflows/terraform.yml`, `terraform/bootstrap/oidc.tf` | [0008](adr/0008-remote-state-and-oidc-cicd.md) |
| Automation | One-command bring-up + platform bootstrap | `Makefile`, `k8s/platform/bootstrap.sh` | — |
| Pipeline as code | Jenkins job seeded via JCasC + Job DSL | `jenkins/casc.yaml` | — |
| Decisions | 10 Architecture Decision Records | `docs/adr/` | — |
| Deferred (documented) | Region DR; secret management | — | [0006](adr/0006-single-region-multi-az-dr-deferred.md), [0009](adr/0009-secret-management.md) |
