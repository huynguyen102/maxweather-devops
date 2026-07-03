# CLAUDE.md — Max Weather DevOps

Project guide for Claude Code (and any contributor). This is the single source of convention and working protocol for this repository; AI-assisted changes must follow it.

## What this is
Solution to the 101 Digital DevOps Technical Assessment: deploy a weather-forecast platform ("Max Weather") on AWS with high availability, autoscaling, OAuth2-protected APIs, CI/CD, and centralized logging — all provisioned via modular Terraform.

- Architecture: [docs/architecture.md](docs/architecture.md)
- Decisions: [docs/adr/](docs/adr/)
- Progress: [TRACKER.md](TRACKER.md)

## Who the author is
Huy Nguyen (huy.devops.engineer@gmail.com) — Senior DevOps / SRE, ~6 years across DevOps, SRE, and ML infrastructure.
- Multi-cloud (AWS, Azure, GCP) and Kubernetes (EKS, AKS, GKE); strong Terraform (IaC) and CI/CD across GitHub Actions, Jenkins, GitLab, Azure DevOps.
- Built SRE foundations from scratch: incident response, on-call, SLOs, observability.
- AI-augmented engineering with Claude Code; also a DevOps instructor.

**Implications for how to work here:**
- Assume a senior audience — do **not** over-explain basics; be concise and actionable.
- Hold a **production-readiness bar**: HA, autoscaling, observability, and security are acceptance criteria, not extras.
- Instructor mindset — documentation should make the *reasoning* legible, not just list steps.

## Working protocol
1. **Ground before you claim.** Read the authoritative source first (code, runtime, live AWS) before asserting. Label statements *verified* vs *assumption*; never present an assumption as fact. Treat any README/doc as possibly stale — cross-check against code and actual cloud state.
2. **Plan before execution, with approval gates.** The first deliverable of multi-step work is the plan (phases, outputs, gates) — it lives in [TRACKER.md](TRACKER.md). Don't run steps before the plan is locked.
3. **Co-build for understanding, not speed.** For any deliverable with 3+ distinct parts, present the structure first, confirm the order, then work block-by-block — surface raw findings before final prose. The goal is that the author can defend the work to a reviewer. Skip only for trivial single-step tasks or when told "just do it".
4. **Answer first; options carry rationale.** Answer in plain text before offering to build. Every next-step menu states, per option, what it buys / de-risks / costs — then recommends one. No bare lists.
5. **No false ownership.** Never write first-person claims that the author did work he didn't. Attribute research neutrally ("from the terraform plan", "from the cluster") without inventing ownership.
6. **Persist & propagate.** Record decisions as ADRs, keep TRACKER updated, and when a rule changes, update every surface that states it.

Language: Vietnamese for back-and-forth discussion; English for anything committed or shared (repo files, docs, commits).

## Phase review — so the author can defend the work
The delivery package (repo + docs) is read by the reviewer on its own; the meeting is **questions, not a presentation**. So the review has two aims: (1) the package stands alone — readable without a walkthrough — and (2) the author can answer any question a reviewer might drill into. At the end of each build phase, before committing, walk the output as a teaching session toward those aims — not a checklist gate, and not a rehearsed talk.

**Altitude — this is a DevOps/SRE review, not a code review.** Explain at the level of control plane vs data plane, architecture, request/data flow, failure modes, scaling, delivery (CI/CD, IaC), and observability. Do NOT walk code internals (syntax, per-line logic, library choices) unless the author explicitly asks — the author reasons about systems, not source.

**Order** — the review replays the order the project was built, top-down: problem & goals → way of working (AI-assisted discipline) → architecture (control/data plane, flow) → DevOps (IaC, CI/CD) → SRE (HA, scaling, observability, failure modes).

Five blocks, delivered one at a time; the author interrupts to question or push back:
1. **What it is & which requirement it solves** — plain terms; explain any unfamiliar concept with an example first.
2. **How it works** — the flow in enough detail to redraw on a whiteboard (who calls whom, where traffic goes).
3. **Why this, not the alternative** — the decision and the rejected option; this is where reviewers dig hardest.
4. **"If asked X, answer Y"** — the 3-4 most likely questions with crisp, in-the-author's-voice answers.
5. **Where in the repo** — files/lines to point at during a live demo.

The phase is "understood" when the author can restate it unaided — only then commit + update TRACKER. Talking points live in their natural home: ADRs (why / alternatives), `architecture.md` (flow), module READMEs (config). If the review surfaces a point not yet captured, add it to the relevant ADR (one home per fact). Convention checks (naming, tagging, module anatomy, no secrets) are done silently and raised only when something is off.

## Environment
Commands assume macOS / zsh with `aws`, `kubectl`, `terraform`, `docker`, and `terraform-docs` installed and AWS credentials configured. Don't emit syntax for a shell that isn't in use.

## Repo map
```
app/        Flask weather proxy + Dockerfile
terraform/  root + modules/{vpc,ecr,eks,cognito,lambda-authorizer,api-gateway,cloudwatch}
k8s/        Deployment, Service, Nginx Ingress Controller, Ingress, HPA
jenkins/    Jenkinsfile (build → ECR → deploy staging → approval → prod)
postman/    API collection with OAuth2 auth flow
docs/       architecture, naming-and-tagging, configuration, adr/
```

## Conventions
- **Naming**: `{project}-{env}-{component}` → root computes `local.name_prefix`, passes down as `var.name_prefix`. Modules build names from the prefix, never hardcode.
- **Tagging**: set once in `terraform/providers.tf` via `default_tags` — every resource inherits `Project`, `Environment`, `Component`, `ManagedBy=terraform`, `Owner`. Do not thread tags into modules.
- **Terraform module anatomy**: 5 base files — `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`. Big modules split `main.tf` by domain (`cluster.tf`, `node-groups.tf`, `iam.tf`, `addons.tf`). Modules declare `required_providers` in `versions.tf` only — **no provider block inside a module**.
- **Module docs**: `README.md` per module is generated by `terraform-docs`, not hand-written.
- **Commits**: Conventional Commits, one commit per build phase (see TRACKER.md). e.g. `feat(eks): managed node group across 2 AZ`.
- **ADR**: every significant decision gets a record in `docs/adr/` using `template.md`.

## Guardrails
- **Plan before apply** — never `terraform apply` without showing `plan` first.
- **Live AWS is approval-per-time** — any command that mutates real AWS/EKS needs explicit approval *each time*. Subagents are forbidden from mutating the cluster or cloud.
- **Deploy → evidence → destroy** — live deploys exist to capture proof (CloudWatch logs, HPA scaling, API+auth). Run `terraform destroy` after to control cost.
- **No secrets in repo** — no API keys, tokens, or `*.secret.tfvars`. Weather source is Open-Meteo (keyless) by design.
- **Parameterized** — anything environment-specific lives in `variables.tf` + `*.tfvars`, never hardcoded.
- **Don't merge AI output blind** — generated code is reviewed against these conventions before commit.

## Code & docs style
- **Self-contained comments** — comments and docstrings explain *what* the code does and *why*, for someone reading only this repo. Do NOT include external names, dates, "corrected"/"earlier note was wrong" history, or references to tickets/chats/meetings/PRs outside the repo. Encode the *result* of a decision, not its source — the source lives in an ADR.
- **Docs teach** — prefer prose that makes the reasoning legible over bare step lists.

## How to run
Filled in as phases land. See TRACKER.md build order.
- App local: `cd app && ...` (phase 2)
- Terraform: `cd terraform && terraform init && terraform plan -var-file=prod.tfvars` (phase 3)
- Deploy/destroy steps: README.md (phase 7)

## AI-assisted development
Built with Claude Code as a pair, deliberately and transparently. Discipline is kept via this file (conventions + protocol), per-phase Conventional Commits, ADRs for decisions, and `terraform-docs`. Rationale: [docs/adr/0001-ai-assisted-workflow.md](docs/adr/0001-ai-assisted-workflow.md).
