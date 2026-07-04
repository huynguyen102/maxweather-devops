# Jenkins — Host Design & Full-Run Runbook

How the Jenkins host is set up, and the exact steps to run the whole pipeline
end-to-end (Jenkins → build → ECR → EKS → app) by hand before submission.

## Host design

### Demo (this repo)
A single containerized Jenkins, started with `docker compose up`. The controller
runs the jobs on its built-in node. The custom image ([Dockerfile](Dockerfile))
bakes in the toolchain the pipeline calls: `docker` CLI, `aws`, `kubectl`, `kustomize`.

How it reaches everything it needs (see [docker-compose.yml](docker-compose.yml)):
| Need | How | Why |
|---|---|---|
| Build/push images | mount the **host Docker socket** | Docker-out-of-Docker: `docker build/push` runs on the host daemon (colima), not a nested daemon |
| ECR + EKS access | mount **`~/.aws`** (read-only) | `aws` and `kubectl` use your credentials; the pipeline runs `aws eks update-kubeconfig` |
| Source code | mount the **repo** at `/workspace/maxweather` | the job uses it as a local Git SCM source — no GitHub required for the demo |
| No login friction | setup wizard disabled | ephemeral local instance on `localhost` only |

**This is demo-grade, not production.** No auth, mounted host socket, and mounted
credentials are all fine for a throwaway local run — not for a shared server.

### Production (how it would differ)
- Controller on a hardened EC2 instance or as an EKS deployment; jobs run on
  **dedicated agents** (EC2 nodes or EKS pods) that carry the toolchain — the
  controller stays clean.
- Agents assume an **IAM role** (instance profile / IRSA) — no mounted keys.
- Real **auth + RBAC**; secrets in the Jenkins **credentials store**, not mounts.
- SCM = the GitHub repo via **webhook** (push/PR triggers), not a local mount.

## Full run (do this before submitting)

> Costs money — it re-provisions the cluster. Tear down at the end.

### 1. Provision infrastructure + platform
```sh
cd terraform
terraform apply                       # ~15-20 min (EKS)
# then bring up the platform (see ../k8s/platform/README.md):
aws eks update-kubeconfig --name "$(terraform output -raw cluster_name)" --region ap-southeast-1
kubectl apply -f ../k8s/platform/namespaces.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/aws/deploy.yaml
# cluster-autoscaler (substitute role ARN + cluster name) — see ../k8s/platform/README.md
```
Then wire the API Gateway to the ingress NLB (phase-2 apply):
```sh
NLB=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
terraform apply -var api_backend_url="http://$NLB"
```

### 2. Start Jenkins
```sh
cd ../jenkins
docker compose up -d --build          # first build installs the toolchain (~2-3 min)
```
Open http://localhost:8080 (no login — wizard is disabled).

### 3. The pipeline job is created for you (JCasC)
On boot, Jenkins reads `jenkins/casc.yaml` and seeds the `maxweather` pipeline job
from code (Job DSL) — SCM = the GitHub repo, script path `jenkins/Jenkinsfile`. No
manual "New Item": open http://localhost:8080 and the job is already there.

### 4. Run it
- **Build with Parameters**:
  - `AWS_REGION` = `ap-southeast-1`
  - `ECR_REPO` = `terraform output -raw ecr_repository_url`
  - `CLUSTER_NAME` = `terraform output -raw cluster_name`
- Watch the stages: Build & test → Push → Deploy staging → **Approve production** → Deploy prod.
- Click **Approve** at the gate to promote to prod.

### 5. Verify
```sh
cd ../terraform
newman run ../postman/MaxWeather.postman_collection.json \
  --env-var base_url="$(terraform output -raw api_endpoint)" \
  --env-var token_url="$(terraform output -raw cognito_token_endpoint)" \
  --env-var client_id="$(terraform output -raw cognito_client_id)" \
  --env-var client_secret="$(terraform output -raw cognito_client_secret)" \
  --env-var scope="$(terraform output -raw cognito_scope)"
```

### 6. Tear down (order matters — see docs/evidence.md notes)
```sh
kubectl delete svc ingress-nginx-controller -n ingress-nginx   # removes the NLB first
aws ecr batch-delete-image --repository-name maxweather-prod-app --region ap-southeast-1 \
  --image-ids "$(aws ecr list-images --repository-name maxweather-prod-app --region ap-southeast-1 --query 'imageIds[*]' --output json)"
cd terraform && terraform destroy
cd ../jenkins && docker compose down          # -v also removes Jenkins home
```
