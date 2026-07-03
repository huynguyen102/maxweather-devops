# Platform components

Cluster-wide pieces the app depends on, applied once per cluster (not per namespace).
Apply these after `terraform apply` creates the cluster and you have a kubeconfig:

```sh
aws eks update-kubeconfig --name "$(terraform -chdir=../terraform output -raw cluster_name)" --region <region>
```

## 1. Namespaces
```sh
kubectl apply -f namespaces.yaml
```

## 2. metrics-server
The HPA reads pod CPU from the metrics API, which EKS does **not** install by
default. Without it the HPA cannot scale. Pinned release:
```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml
kubectl -n kube-system rollout status deploy/metrics-server
```

## 3. Nginx Ingress Controller (AWS)
The AWS provider manifest creates the Service of type LoadBalancer, which
provisions the NLB that fronts the Ingress. Pinned release:
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/aws/deploy.yaml
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller
```
Get the NLB hostname (this is the `api_backend_url` for the API Gateway, phase 8):
```sh
kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 4. Cluster Autoscaler
Scales the node group when pods can't be scheduled. Substitute the IRSA role ARN
and cluster name from Terraform outputs, then apply:
```sh
export CA_ROLE_ARN="$(terraform -chdir=../terraform output -raw cluster_autoscaler_role_arn)"
export CLUSTER_NAME="$(terraform -chdir=../terraform output -raw cluster_name)"
sed -e "s|<CLUSTER_AUTOSCALER_ROLE_ARN>|$CA_ROLE_ARN|" \
    -e "s|<CLUSTER_NAME>|$CLUSTER_NAME|" \
    cluster-autoscaler.yaml | kubectl apply -f -
kubectl -n kube-system rollout status deploy/cluster-autoscaler
```

## 5. Deploy the app
```sh
cd ../k8s
kustomize edit set image maxweather-app="$(terraform -chdir=../terraform output -raw ecr_repository_url):<tag>"   # run inside overlays/<env>
kubectl apply -k overlays/staging
kubectl apply -k overlays/prod
```

## Validate manifests offline
```sh
kubeconform -strict -summary namespaces.yaml
# cluster-autoscaler uses standard resources; validate after substitution or ignore placeholders
```
