# Max Weather DevOps — Tracker

Plan of record for the 101 Digital DevOps Technical Assessment. Tick each phase and record evidence as it lands.

Status: `[ ]` not started · `[~]` in progress · `[x]` done

## Phase Review Gate (end of each phase, before commit)
The delivery package is read by the reviewer on its own; the meeting is **questions, not a presentation**. Review makes sure (1) the package stands alone and (2) the author can **defend any part under questioning**. Altitude is DevOps/SRE — control plane vs data plane, architecture, flow, delivery, observability — **not** code internals. Five blocks: (1) what it is & which requirement it solves · (2) how it works (whiteboard-level) · (3) why this, not the alternative · (4) "if asked X, answer Y" · (5) point at files in the repo. Talking points live in ADRs / architecture.md / module READMEs; if the review surfaces a new point, add it to the relevant ADR. Details: [CLAUDE.md](CLAUDE.md#phase-review--so-the-author-can-defend-the-work).

---

## Operating principles
1. **Leave a process trail** — ADRs + Conventional Commits + `terraform-docs`; README states AI-assisted with Claude Code.
2. **No scope creep** — deliver exactly the 6 deliverables, nothing more.
3. **Real AWS** — use EKS/API Gateway as the brief requires; take best practices from prior work, drop the free-tier cost workarounds.

## Locked decisions
| Topic | Decision |
|---|---|
| Deploy | Live to real AWS → capture evidence → `terraform destroy` |
| OAuth2 | Cognito (issuer) + custom Lambda authorizer (validate JWT) |
| Staging/Prod | One EKS cluster, two namespaces — no duplicated infrastructure |
| App | Python Flask |
| Weather API | Open-Meteo (keyless, self-contained) |
| Jenkins | Jenkinsfile runnable on any Jenkins + docker-compose for local demo |

## Architecture
```
Frontend → API Gateway (proxy) → Lambda Authorizer → validate Cognito JWT
                │
                ▼  NLB → Nginx Ingress → Service → Deployment (pods → Open-Meteo)
   HA: VPC 2 AZ, node group 2 AZ · Scale: HPA + Cluster Autoscaler · Logs: Container Insights → CloudWatch
```

## Scope contract (6 deliverables)
| # | Deliverable | Out of scope |
|---|---|---|
| 1 | Architecture diagram | no multiple views |
| 2 | Modular, parameterized Terraform | no multi-region/multi-env, no complex remote state |
| 3 | K8s: Deployment, Service, Nginx Ingress Controller, Ingress (+HPA) | no Helm/service mesh |
| 4 | Jenkinsfile deploying to the cluster | no multi-branch/shared-lib |
| 5 | API in API Gateway (proxy + authorizer) | no full API resources |
| 6 | Postman collection with auth flow | — |

## Repo layout
```
maxweather-devops/
├── README.md                  # overview + AI-assisted note + deploy/destroy steps
├── CLAUDE.md                  # conventions + guardrails for Claude Code (evidence of disciplined AI use)
├── TRACKER.md                 # this file
├── .gitignore
├── docs/
│   ├── architecture.md         # Mermaid diagram + PNG
│   ├── naming-and-tagging.md   # convention ↔ enforced via locals + default_tags
│   ├── configuration.md        # module contract (terraform-docs)
│   └── adr/                    # template + 0001-ai-assisted..0005-open-meteo
├── app/                        # Flask weather proxy + Dockerfile
├── terraform/
│   ├── providers.tf versions.tf locals.tf variables.tf main.tf outputs.tf
│   ├── terraform.tfvars prod.tfvars
│   └── modules/{vpc,ecr,eks,cognito,lambda-authorizer,api-gateway,cloudwatch}
│       └── each module: main.tf variables.tf outputs.tf versions.tf README.md (+locals/data as needed)
├── k8s/                        # deployment, service, ingress-controller, ingress, hpa
├── jenkins/Jenkinsfile
└── postman/
```

## Conventions
- **Naming**: `{project}-{env}-{component}` → root computes `local.name_prefix`, passes it down.
- **Tags** (via `default_tags`): Project · Environment · Component · ManagedBy=terraform · Owner=huy.devops.engineer@gmail.com.
- **Module**: 5 base files (`main/variables/outputs/versions/README`); large modules split `main.tf` by domain (`cluster/node-groups/iam/addons`). No provider block inside a module.

---

## Build order
| # | Phase | Status | Evidence / notes |
|---|---|---|---|
| 1 | Scaffold repo + README + CLAUDE.md + ADRs | `[x]` | README, CLAUDE.md, .gitignore, docs/adr/{template,0001-0005} |
| 2 | Architecture & design — docs/architecture.md (diagram + flow + component roles) | `[x]` | docs/architecture.md — Mermaid + control/data plane + failure modes; verify vs reality in phase 8 |
| 3 | App Flask + Dockerfile (test local) | `[x]` | app.py + Dockerfile + README; verified: docker build + run, /health, real /forecast, 400 on bad input |
| 4 | Terraform: vpc → ecr → eks → cognito → lambda-authorizer → api-gateway → cloudwatch | `[x]` | 7 modules, root wiring; terraform validate = Success; plan/apply at phase 8 (needs creds) |
| 5 | K8s YAML (deployment/service/ingress-controller/ingress/hpa) | `[x]` | kustomize base + staging/prod overlays; platform: namespaces, metrics-server, ingress-nginx, cluster-autoscaler; kubeconform valid |
| 6 | Jenkinsfile | `[x]` | declarative pipeline build→ECR→staging→approval→prod; validated green via pipeline-model-converter (real Jenkins in Docker) |
| 7 | Postman collection | `[ ]` | |
| 8 | Deploy live → evidence (CloudWatch logs, HPA scale, API+auth) → destroy + verify diagram matches reality | `[ ]` | |

## Deliverable ↔ phase (submission checklist)
- [ ] 1. Architecture diagram — phase 2 (verified against reality in phase 8)
- [ ] 2. Modular Terraform (tested before submission) — phase 4, 8
- [ ] 3. K8s artifacts — phase 5
- [ ] 4. Jenkins pipeline — phase 6
- [ ] 5. App API in API Gateway — phase 4, 8
- [ ] 6. Postman with auth — phase 7, 8
- [ ] Email submission to anurudda@ + rajiv@101digital.io with Gitrepo ID + email
