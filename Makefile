# Automation for the infrastructure + platform lifecycle.
# The application lifecycle is Jenkins (jenkins/Jenkinsfile) — see jenkins/RUNBOOK.md.
# Targets are small and composable; values come from Terraform outputs, nothing hardcoded.
#
#   make up        # infra -> platform -> wire  (full bring-up)
#   make verify    # prove it works (Postman/newman)
#   make destroy   # tear down in the correct order
#
# Two human gates are intentional, not missing automation:
#   - `terraform apply` shows the plan and asks to confirm (review before creating)
#   - the Jenkins pipeline pauses for manual approval before promoting to prod

REGION ?= ap-southeast-1
TF     := terraform -chdir=terraform

.DEFAULT_GOAL := help
.PHONY: help up infra platform wire deploy-app verify destroy

help: ## show this list
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up: infra platform wire ## full bring-up: infra + platform + wire API Gateway
	@echo ">> infra + platform ready. Deploy the app via Jenkins (jenkins/RUNBOOK.md), then: make verify"

infra: ## provision AWS: VPC, EKS, ECR, Cognito, authorizer, API Gateway, CloudWatch
	$(TF) init -input=false
	$(TF) apply

platform: ## kubeconfig + namespaces + metrics-server + ingress-nginx + cluster-autoscaler
	bash k8s/platform/bootstrap.sh

wire: ## point API Gateway at the ingress NLB (phase-2 apply)
	@NLB=$$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
	test -n "$$NLB" || { echo "NLB not ready yet — wait a minute and retry"; exit 1; }; \
	echo ">> wiring API Gateway to http://$$NLB"; \
	$(TF) apply -var api_backend_url="http://$$NLB"

deploy-app: ## dev convenience: build+push+deploy by hand (the real path is Jenkins)
	@REPO=$$($(TF) output -raw ecr_repository_url); SHA=$$(git rev-parse --short HEAD); \
	echo ">> build+push $$REPO:$$SHA (linux/amd64)"; \
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $$REPO; \
	docker build --platform linux/amd64 -t $$REPO:$$SHA app/; \
	docker push $$REPO:$$SHA; \
	( cd k8s/overlays/prod && kustomize edit set image maxweather-app=$$REPO:$$SHA ); \
	kubectl apply -k k8s/overlays/prod; \
	kubectl -n prod rollout status deploy/maxweather; \
	git checkout k8s/overlays/prod/kustomization.yaml

verify: ## run the Postman collection (token / authorized / denied)
	newman run postman/MaxWeather.postman_collection.json \
	  --env-var base_url="$$($(TF) output -raw api_endpoint)" \
	  --env-var token_url="$$($(TF) output -raw cognito_token_endpoint)" \
	  --env-var client_id="$$($(TF) output -raw cognito_client_id)" \
	  --env-var client_secret="$$($(TF) output -raw cognito_client_secret)" \
	  --env-var scope="$$($(TF) output -raw cognito_scope)"

destroy: ## tear down in order: NLB + ECR images, then terraform destroy
	-kubectl delete svc ingress-nginx-controller -n ingress-nginx
	-@IMGS=$$(aws ecr list-images --repository-name maxweather-prod-app --region $(REGION) --query 'imageIds[*]' --output json 2>/dev/null); \
	  [ "$$IMGS" != "[]" ] && [ -n "$$IMGS" ] && aws ecr batch-delete-image --repository-name maxweather-prod-app --region $(REGION) --image-ids "$$IMGS" >/dev/null || true
	$(TF) destroy
