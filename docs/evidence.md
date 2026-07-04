# Live Verification Evidence

Captured from a live deployment on AWS (account `905418181527`, region `ap-southeast-1`).
Each section maps to a requirement and shows the command plus the observed result.
The stack was torn down with `terraform destroy` after capture.

## Infrastructure provisioned (Terraform)
`terraform apply` created the full stack (VPC, EKS, ECR, Cognito, Lambda authorizer,
API Gateway, CloudWatch) — 54 managed resources. Key outputs:
```
api_endpoint           = https://g7m7hj49w3.execute-api.ap-southeast-1.amazonaws.com
cluster_name           = maxweather-prod-eks
ecr_repository_url     = 905418181527.dkr.ecr.ap-southeast-1.amazonaws.com/maxweather-prod-app
cognito_token_endpoint = https://maxweather-prod.auth.ap-southeast-1.amazoncognito.com/oauth2/token
```

## Req #1 — High availability (multi-AZ)
`kubectl get pods -n prod -o wide` — 2 replicas on **two different nodes** (different AZs):
```
maxweather-7bfdcd494b-bg2g6   1/1   Running   ip-10-0-141-86...   (AZ a)
maxweather-7bfdcd494b-mt4mh   1/1   Running   ip-10-0-150-37...   (AZ b)
```

## Req #2 — Autoscaling
`kubectl get hpa -n prod` — HPA is live and reading CPU from metrics-server:
```
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS
maxweather   Deployment/maxweather   cpu: 2%/60%      2         10         2
```
`kubectl top pods -n prod` (proves metrics-server is serving):
```
maxweather-7bfdcd494b-bg2g6   2m   84Mi
maxweather-7bfdcd494b-mt4mh   3m   85Mi
```
Node tier: `cluster-autoscaler` running in `kube-system` with the IRSA role, discovering the node ASG by tag.

## Req #3 & #4 — API exposed + OAuth2 protection
`newman run postman/MaxWeather.postman_collection.json` against the live API Gateway — **5/5 assertions passed**:
```
→ 1. Get OAuth2 token      POST .../oauth2/token          [200 OK]   ✓ token issued  ✓ has access_token
→ 2. Get forecast (auth)   GET  .../forecast?lat&lon       [200 OK]   ✓ 200 OK        ✓ has current weather
→ 3. Get forecast (no tok) GET  .../forecast?lat&lon       [401]      ✓ rejected without a token
assertions: 5 executed, 0 failed
```
This exercises the full chain: **API Gateway → Lambda authorizer (Cognito JWT) → NLB → Nginx Ingress → prod pod → Open-Meteo**. A valid token returns forecast data; no token is rejected with 401.

Data-plane path also confirmed directly (ingress has no auth; auth is enforced at API Gateway):
```
curl http://<nlb>/health   -> {"status":"ok"}
curl http://<nlb>/forecast -> {"current":{"temperature_2m":27.1,...},"daily":{...}}
```

## Req #6 — Centralized logging (CloudWatch)
App logs (structured JSON) reach CloudWatch via the amazon-cloudwatch-observability
addon (Fluent Bit). Sample from `/aws/containerinsights/maxweather-prod-eks/application`:
```json
{"level":"INFO","logger":"maxweather","message":"forecast served","lat":10.82,"lon":106.63}
```
Fluent Bit enriches each record with Kubernetes metadata (pod, namespace,
container image `maxweather-prod-app:a4fe52a`), and the nginx ingress access logs
are captured in the same group.

## Notes
- The app is I/O-bound (a thin proxy to Open-Meteo), so CPU stays low; a sustained
  scale-out demo needs concurrent load heavy enough to raise CPU above the 60% target.
- API Gateway control-plane and NLB were provisioned in `ap-southeast-1`; the API
  endpoint above was live at capture time and removed on teardown.
