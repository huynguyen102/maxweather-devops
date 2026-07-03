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
docker compose up -d
# initial admin password:
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
Open http://localhost:8080, install suggested plugins, create a **Pipeline** job
with "Pipeline script from SCM" pointing at this repo and script path
`jenkins/Jenkinsfile`, then run with the parameters above.

> The stock `jenkins/jenkins` image has no `docker`/`aws`/`kubectl`/`kustomize`.
> For a real run, use an agent image that bundles them (or install them on the
> controller for a demo). The compose file mounts the Docker socket so the build
> stage can reach the host Docker.

## Validate the Jenkinsfile
```sh
# against a running Jenkins with the Pipeline: Model Definition plugin:
curl -s -X POST -F "jenkinsfile=<Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
# -> "Jenkinsfile successfully validated."
```
