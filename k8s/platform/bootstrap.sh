#!/usr/bin/env bash
# Platform bootstrap — the one-time, cluster-wide setup the app depends on.
#
# It reads the cluster name and the autoscaler role ARN from `terraform output`
# (single source of truth — nothing hardcoded), then installs, in order:
#   1. kubeconfig        - point kubectl at the cluster
#   2. namespaces        - staging + prod partitions
#   3. metrics-server    - feeds pod CPU to the HPA (EKS doesn't ship it)
#   4. ingress-nginx     - creates the public NLB and routes Ingress rules
#   5. cluster-autoscaler- scales nodes when pods can't be scheduled
#
# Safe to re-run: every install is `kubectl apply` (idempotent).
# Usage:  bash k8s/platform/bootstrap.sh
set -euo pipefail

# Pinned versions — bump deliberately, not by accident.
METRICS_SERVER_VERSION="v0.7.2"
INGRESS_NGINX_VERSION="controller-v1.11.3"

HERE="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$(cd "$HERE/../../terraform" && pwd)"

# Values come from Terraform state / your AWS config — never pasted by hand.
REGION="$(aws configure get region 2>/dev/null || echo ap-southeast-1)"
CLUSTER="$(terraform -chdir="$TF_DIR" output -raw cluster_name)"
CA_ROLE_ARN="$(terraform -chdir="$TF_DIR" output -raw cluster_autoscaler_role_arn)"

echo ">> cluster=$CLUSTER  region=$REGION"

echo ">> [1/5] kubeconfig — teach kubectl how to reach this cluster"
aws eks update-kubeconfig --name "$CLUSTER" --region "$REGION"

echo ">> [2/5] namespaces — staging + prod"
kubectl apply -f "$HERE/namespaces.yaml"

echo ">> [3/5] metrics-server $METRICS_SERVER_VERSION — CPU sensor for the HPA"
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"

echo ">> [4/5] ingress-nginx $INGRESS_NGINX_VERSION — NLB + L7 routing"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/aws/deploy.yaml"

echo ">> [5/5] cluster-autoscaler — node scaling (role ARN + cluster name injected)"
sed -e "s|<CLUSTER_AUTOSCALER_ROLE_ARN>|${CA_ROLE_ARN}|" \
    -e "s|<CLUSTER_NAME>|${CLUSTER}|" \
    "$HERE/cluster-autoscaler.yaml" | kubectl apply -f -

echo ">> waiting for platform to be ready..."
kubectl -n kube-system   rollout status deploy/metrics-server            --timeout=180s
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller  --timeout=180s
kubectl -n kube-system   rollout status deploy/cluster-autoscaler        --timeout=180s

echo ">> waiting for the ingress NLB hostname (AWS provisions it async)..."
NLB=""
for _ in $(seq 1 30); do
  NLB="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
  [ -n "$NLB" ] && break
  sleep 5
done

echo
echo "================================================================"
echo "platform ready."
echo "ingress NLB: ${NLB:-<still pending — re-check in a minute>}"
echo
echo "next — wire API Gateway to the NLB (phase-2 apply):"
echo "  terraform -chdir=\"$TF_DIR\" apply -var api_backend_url=\"http://${NLB}\""
echo "================================================================"
