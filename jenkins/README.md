# Jenkins pipeline

`Jenkinsfile` is a declarative pipeline that builds the app image once, tests it,
pushes it to ECR, deploys to **staging**, waits for **manual approval**, then
promotes the **same image** to **production**. Building once and promoting the
identical artifact is what makes "tested in staging" meaningful.

## Stages
1. **Checkout** — derive the image tag from the short commit SHA (immutable, traceable).
2. **Build & test image** — `docker build`, run the container, hit `/health` before it can ship.
3. **Push to ECR** — log in and push `:$IMAGE_TAG`.
4. **Deploy to staging** — set the image in the staging overlay, `kubectl apply -k`, wait for rollout.
5. **Verify staging** — list the pods.
6. **Approve production** — manual `input` gate.
7. **Deploy to production** — same image into the prod overlay, wait for rollout.
8. **Verify production** — list the pods.

## Parameters
| Parameter | Example | Source |
|---|---|---|
| `AWS_REGION` | `ap-southeast-1` | your region |
| `ECR_REPO` | `<acct>.dkr.ecr.<region>.amazonaws.com/maxweather-prod-app` | `terraform output -raw ecr_repository_url` |
| `CLUSTER_NAME` | `maxweather-prod-eks` | `terraform output -raw cluster_name` |

## What the agent needs
The build node must have: `docker`, `aws` CLI, `kubectl`, `kustomize`, and AWS
credentials with permission to push to ECR and reach the EKS cluster (an EC2 agent
with an instance profile, or configured credentials).

## Run Jenkins locally (demo)
```sh
docker compose up -d --build
```
`docker compose` builds a tool-equipped image ([Dockerfile](Dockerfile): Jenkins +
`docker`/`aws`/`kubectl`/`kustomize` + pipeline plugins, setup wizard disabled) and
mounts the Docker socket, `~/.aws`, and the repo. Open http://localhost:8080 (no login).

**The full host design and the exact end-to-end run steps (provision → run pipeline
→ approve → verify → tear down) are in [RUNBOOK.md](RUNBOOK.md).**

There is also an infra pipeline skeleton, [Jenkinsfile.infra](Jenkinsfile.infra)
(bonus — see [ADR-0007](../docs/adr/0007-app-cicd-now-infra-cicd-next.md)).

## Validate the Jenkinsfile
```sh
# against a running Jenkins with the Pipeline: Model Definition plugin:
curl -s -X POST -F "jenkinsfile=<Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
# -> "Jenkinsfile successfully validated."
```
