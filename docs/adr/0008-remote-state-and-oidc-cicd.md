# ADR 0008 — Remote state + OIDC for CI/CD

- **Status**: Accepted
- **Deciders**: Huy Nguyen

## Context
Two hardening items were deferred in [ADR-0007](0007-app-cicd-now-infra-cicd-next.md) and are now implemented:

1. **State** was local and plaintext (it holds sensitive values such as the Cognito client secret). Local state has no sharing, no locking, and no encryption at rest.
2. **CI/CD authenticated to AWS with long-lived keys** (a developer's `aws configure`, and the demo Jenkins mounted `~/.aws`). Long-lived keys are the most common cloud credential leak.

## Decision
- **Remote state**: an S3 bucket (versioned, SSE-encrypted, public access blocked) plus a DynamoDB lock table. Created once by `terraform/bootstrap`; the main stack uses it via `backend "s3"`.
- **OIDC for CI/CD**: an IAM OIDC provider for GitHub Actions plus a `maxweather-ci` role whose trust policy is scoped to this repository. The GitHub Actions workflow assumes that role with a short-lived OIDC token — **no static AWS keys exist in the repo or in GitHub**. The role is read-only for the plan pipeline.

`terraform/bootstrap` uses local state itself (it cannot store state in a bucket it hasn't created — the chicken-and-egg every remote-state setup has).

## Alternatives considered
- **Keep long-lived keys in GitHub secrets** — simpler, but a standing credential to leak/rotate. OIDC removes it entirely.
- **Hardcode backend config** vs partial config — hardcoded `backend.tf` is used for this single-account submission; another account changes the bucket name (documented).

## Consequences
- Positive: state is encrypted, versioned, and lockable; CI has no static AWS credentials; the trust policy limits assumption to this repo.
- Negative / trade-offs: a one-time bootstrap must run before the main stack; the account ID appears in `backend.tf` and the workflow role ARN (low-sensitivity, acceptable for this submission).
- The Jenkins app pipeline still uses mounted host credentials in the local demo; on a real Jenkins it would use an agent instance-profile/IRSA role — the same keyless principle.
