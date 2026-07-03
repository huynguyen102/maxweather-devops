# Max Weather — DevOps Assessment

Production-ready weather-forecast platform on AWS: highly available, autoscaling, OAuth2-protected APIs, CI/CD, and centralized logging — provisioned with modular Terraform. Solution to the 101 Digital DevOps Technical Assessment.

## Architecture
```
Frontend → API Gateway (proxy) → Lambda Authorizer → validate Cognito JWT
                │
                ▼  NLB → Nginx Ingress → Service → Deployment (pods → Open-Meteo)
   HA: VPC 2 AZ, node group 2 AZ · Scale: HPA + Cluster Autoscaler · Logs: Container Insights → CloudWatch
```
Full diagram + component walkthrough: [docs/architecture.md](docs/architecture.md).

## Repo map
| Path | Contents |
|---|---|
| [app/](app/) | Flask weather proxy + Dockerfile |
| [terraform/](terraform/) | Root config + `modules/{vpc,ecr,eks,cognito,lambda-authorizer,api-gateway,cloudwatch}` |
| [k8s/](k8s/) | Deployment, Service, Nginx Ingress Controller, Ingress, HPA |
| [jenkins/](jenkins/) | Jenkinsfile: build → ECR → deploy staging → approval → prod |
| [postman/](postman/) | API collection with OAuth2 auth flow |
| [docs/](docs/) | Architecture, naming & tagging, configuration, ADRs |

## Deliverables (assessment)
| # | Deliverable | Where |
|---|---|---|
| 1 | Architecture diagram | [docs/architecture.md](docs/architecture.md) |
| 2 | Modular Terraform | [terraform/](terraform/) |
| 3 | K8s artifacts | [k8s/](k8s/) |
| 4 | Jenkins pipeline | [jenkins/Jenkinsfile](jenkins/Jenkinsfile) |
| 5 | API in API Gateway | [terraform/modules/api-gateway/](terraform/modules/api-gateway/) |
| 6 | Postman collection | [postman/](postman/) |

## Getting started
Deploy/destroy steps land in phase 7. Conventions and guardrails: [CLAUDE.md](CLAUDE.md). Progress: [TRACKER.md](TRACKER.md).

## AI-assisted development
This solution was built with **Claude Code** as a pair-programming assistant, deliberately and transparently. Engineering discipline is preserved through:
- [CLAUDE.md](CLAUDE.md) — a single source of conventions the assistant follows (naming, tagging, module anatomy, guardrails)
- One Conventional Commit per build phase — the git log reads as the process
- Architecture Decision Records in [docs/adr/](docs/adr/)
- `terraform-docs`-generated module documentation

Rationale: [docs/adr/0001-ai-assisted-workflow.md](docs/adr/0001-ai-assisted-workflow.md).
