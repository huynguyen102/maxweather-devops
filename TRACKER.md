# Max Weather DevOps — Tracker

Plan of record cho bài DevOps Technical Assessment (101 Digital). Mỗi phase làm xong tick `[x]` và ghi bằng chứng.

Status: `[ ]` chưa · `[~]` đang làm · `[x]` xong

## Phase Review Gate (cuối mỗi phase, trước khi commit)
Review = walkthrough để tác giả **trình bày lại được trong meeting**, không phải checklist. 5 khối: (1) cái gì & giải requirement nào · (2) cách nó chạy (vẽ được whiteboard) · (3) vì sao chọn cách này, không chọn cách kia · (4) "nếu bị hỏi X trả lời Y" · (5) chỉ vào file/dòng trong repo. Tác giả nói lại được → mới commit + tick TRACKER. Đạn trình bày nằm ở ADR / architecture.md / module README; review lòi point mới thì bổ sung vào ADR. Chi tiết: [CLAUDE.md](CLAUDE.md#phase-review--so-the-author-can-present-the-work).

---

## Nguyên tắc vận hành
1. **Lộ dấu vết process** — ADR + conventional commits + `terraform-docs`; README ghi rõ AI-assisted với Claude Code.
2. **Không nở scope** — làm đúng 6 deliverable, không hơn.
3. **AWS thật** — dùng EKS/API Gateway đúng đề; lấy best practice từ ProOps2026, bỏ phần tiết kiệm free-tier.

## Quyết định đã khóa
| Vấn đề | Chốt |
|---|---|
| Deploy | Live lên AWS → chụp bằng chứng → `terraform destroy` |
| OAuth2 | Cognito (issuer) + Lambda authorizer (validate JWT) |
| Staging/Prod | 1 EKS cluster, 2 namespace — không nhân đôi hạ tầng |
| App | Python Flask |
| Weather API | Open-Meteo (không cần key, self-contained) |
| Jenkins | Jenkinsfile chạy trên Jenkins bất kỳ + docker-compose demo local |

## Kiến trúc
```
Frontend → API Gateway (proxy) → Lambda Authorizer → validate Cognito JWT
                │
                ▼  NLB → Nginx Ingress → Service → Deployment (pods → Open-Meteo)
   HA: VPC 2 AZ, node group 2 AZ · Scale: HPA + Cluster Autoscaler · Logs: Container Insights → CloudWatch
```

## Scope contract (6 deliverable)
| # | Món | KHÔNG làm |
|---|---|---|
| 1 | Architecture diagram | không nhiều view |
| 2 | Terraform modular + parameterized | không multi-region/multi-env, không remote-state phức tạp |
| 3 | K8s: Deployment, Service, Nginx Ingress Controller, Ingress (+HPA) | không Helm/service mesh |
| 4 | Jenkinsfile deploy vào cluster | không multi-branch/shared-lib |
| 5 | API trong API Gateway (proxy + authorizer) | không tạo full API resources |
| 6 | Postman collection có auth flow | — |

## Repo layout
```
maxweather-devops/
├── README.md                  # overview + AI-assisted note + deploy/destroy steps
├── CLAUDE.md                  # convention + guardrails cho Claude Code (bằng chứng AI có kỷ luật)
├── TRACKER.md                 # file này
├── .gitignore
├── docs/
│   ├── architecture.md         # Mermaid + PNG
│   ├── naming-and-tagging.md   # convention ↔ enforce bằng locals + default_tags
│   ├── configuration.md        # module contract (terraform-docs)
│   └── adr/                    # template + 0001-ai-assisted..0005-open-meteo
├── app/                        # Flask weather proxy + Dockerfile
├── terraform/
│   ├── providers.tf versions.tf locals.tf variables.tf main.tf outputs.tf
│   ├── terraform.tfvars prod.tfvars
│   └── modules/{vpc,ecr,eks,cognito,lambda-authorizer,api-gateway,cloudwatch}
│       └── mỗi module: main.tf variables.tf outputs.tf versions.tf README.md (+locals/data khi cần)
├── k8s/                        # deployment, service, ingress-controller, ingress, hpa
├── jenkins/Jenkinsfile
└── postman/
```

## Convention chốt
- **Naming**: `{project}-{env}-{component}` → root tính `local.name_prefix`, truyền xuống module.
- **Tag** (qua `default_tags`): Project · Environment · Component · ManagedBy=terraform · Owner=huy.devops.engineer@gmail.com.
- **Module**: 5 file base (`main/variables/outputs/versions/README`); module lớn tách `main.tf` theo domain (`cluster/node-groups/iam/addons`). Module không chứa provider block.

---

## Build order
| # | Phase | Status | Bằng chứng / ghi chú |
|---|---|---|---|
| 1 | Scaffold repo + README + CLAUDE.md + ADR | `[x]` | README, CLAUDE.md, .gitignore, docs/adr/{template,0001-0005} |
| 2 | App Flask + Dockerfile (test local) | `[ ]` | |
| 3 | Terraform: vpc → ecr → eks → cognito → lambda-authorizer → api-gateway → cloudwatch | `[ ]` | |
| 4 | K8s YAML (deployment/service/ingress-controller/ingress/hpa) | `[ ]` | |
| 5 | Jenkinsfile | `[ ]` | |
| 6 | Postman collection | `[ ]` | |
| 7 | Deploy live → bằng chứng (CloudWatch logs, HPA scale, API+auth) → destroy | `[ ]` | |
| 8 | Diagram PNG chốt vào docs | `[ ]` | |

## Deliverable ↔ phase (checklist nộp bài)
- [ ] 1. Architecture diagram — phase 8
- [ ] 2. Terraform modular (test trước khi nộp) — phase 3, 7
- [ ] 3. K8s artifacts — phase 4
- [ ] 4. Jenkins pipeline — phase 5
- [ ] 5. App API trong API Gateway — phase 3, 7
- [ ] 6. Postman có auth — phase 6, 7
- [ ] Email submission cho anurudda@ + rajiv@101digital.io kèm Gitrepo ID + email
