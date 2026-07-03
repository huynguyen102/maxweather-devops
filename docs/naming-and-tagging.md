# Naming & Tagging Convention

This is the single source of truth for how every AWS resource in this project is named and tagged. The convention is not just documentation — it is **enforced in code** (`terraform/locals.tf` and `terraform/providers.tf`), so the naming/tagging you read here is what actually ships.

## Why it matters
- **Cost allocation** — every resource carries `Project`, `Environment`, and `Component` tags, so cost can be sliced by any of them in Cost Explorer / billing.
- **Governance & ownership** — `ManagedBy` and `Owner` tell operators what created a resource and who is responsible.
- **Discovery** — a consistent `{project}-{environment}-...` prefix makes resources findable and unambiguous in the console and CLI.
- **Behaviour** — some tags are functional: Kubernetes and the Cluster Autoscaler discover subnets and Auto Scaling Groups by tag (see [Functional tags](#functional-tags)).

---

## Naming convention

### Pattern
```
{project}-{environment}-{component}[-{qualifier}]
```
- `project` — fixed, `maxweather`
- `environment` — the infrastructure tier, e.g. `prod` (app staging/prod are Kubernetes namespaces, not separate infrastructure — see ADR-0004)
- `component` — the module's domain (see [taxonomy](#component-taxonomy))
- `qualifier` — an optional discriminator when a module has several of the same resource (e.g. AZ index `-1`, `-2`)

### Enforcement
The prefix is computed once in the root and passed down; modules never hardcode names.

```hcl
# terraform/locals.tf
locals {
  name_prefix = "${var.project}-${var.environment}"   # e.g. maxweather-prod
}

# terraform/main.tf — every module receives it
module "vpc" {
  source      = "./modules/vpc"
  name_prefix = local.name_prefix
  ...
}
```

Inside a module, resource names are built from `var.name_prefix`:
```hcl
resource "aws_vpc" "this" {
  tags = { Name = "${var.name_prefix}-vpc" }
}
```

### Resource names (with `name_prefix = maxweather-prod`)

| Module | Resource | Name |
|---|---|---|
| vpc | VPC | `maxweather-prod-vpc` |
| vpc | Internet Gateway | `maxweather-prod-igw` |
| vpc | Public subnets | `maxweather-prod-public-1`, `-2` |
| vpc | Private subnets | `maxweather-prod-private-1`, `-2` |
| vpc | NAT gateways / EIPs | `maxweather-prod-nat-1` (`-2` if per-AZ) |
| vpc | Public route table | `maxweather-prod-public-rt` |
| vpc | Private route tables | `maxweather-prod-private-rt-1` (`-2` if per-AZ) |
| ecr | Repository | `maxweather-prod-app` |
| eks | Cluster | `maxweather-prod-eks` |
| eks | Cluster IAM role | `maxweather-prod-eks-cluster-role` |
| eks | Node IAM role | `maxweather-prod-eks-node-role` |
| eks | Cluster Autoscaler role/policy | `maxweather-prod-eks-cluster-autoscaler` |
| eks | Managed node group | `maxweather-prod-eks-default` |
| cognito | User pool | `maxweather-prod-users` |
| cognito | Hosted domain | `maxweather-prod` |
| cognito | Resource server (identifier) | `maxweather-prod-api` |
| cognito | App client | `maxweather-prod-m2m-client` |
| lambda-authorizer | Function | `maxweather-prod-authorizer` |
| lambda-authorizer | IAM role | `maxweather-prod-authorizer-role` |
| lambda-authorizer | Log group | `/aws/lambda/maxweather-prod-authorizer` |
| api-gateway | HTTP API | `maxweather-prod-api` |
| api-gateway | Authorizer | `maxweather-prod-cognito-authorizer` |
| api-gateway | Access log group | `/aws/apigateway/maxweather-prod-api` |
| cloudwatch | Container Insights log groups | `/aws/containerinsights/maxweather-prod-eks/{application,dataplane,host,performance}` |

> Log group names follow the AWS-conventional `/aws/<service>/...` path form rather than the dash-prefix, because those paths are what the services and the console expect.

### Component taxonomy
| Module | `Component` value |
|---|---|
| vpc | `network` |
| ecr | `registry` |
| eks | `compute` |
| cognito | `identity` |
| lambda-authorizer | `auth` |
| api-gateway | `api` |
| cloudwatch | `observability` |

---

## Tagging policy

Tags fall into three groups: **identity** (applied globally), **descriptive** (per resource), and **functional** (drive behaviour).

### Identity tags — applied to every resource
Set once via the provider's `default_tags`; inherited by all resources in the root **and** all child modules. Modules never re-declare these.

```hcl
# terraform/providers.tf
provider "aws" {
  region = var.region
  default_tags {
    tags = local.common_tags
  }
}

# terraform/locals.tf
locals {
  common_tags = {
    Project     = var.project                        # maxweather
    Environment = var.environment                    # prod
    ManagedBy   = "terraform"
    Owner       = "huy.devops.engineer@gmail.com"
  }
}
```

| Tag | Value | Purpose |
|---|---|---|
| `Project` | `maxweather` | group all resources of the project |
| `Environment` | `prod` | cost/scope by environment |
| `ManagedBy` | `terraform` | signal not to edit by hand |
| `Owner` | `huy.devops.engineer@gmail.com` | responsible contact |

### Descriptive tags — per resource
Each module adds two tags on its own resources:

| Tag | Value | Set by |
|---|---|---|
| `Name` | the resource name (see table above) | each resource block |
| `Component` | the module's taxonomy value | a module-level `local.component` |

`Component` is the one tag a module stamps itself — this keeps the module self-describing without "threading" a tag map through variables. It cannot live in `default_tags` because it differs per module.

```hcl
# inside a module
locals { component = "network" }

resource "aws_vpc" "this" {
  tags = {
    Name      = "${var.name_prefix}-vpc"
    Component = local.component
  }
}
# final tags = default_tags (Project/Environment/ManagedBy/Owner) + { Name, Component }
```

### Functional tags
These are not for governance — services read them to make decisions. They are set only on the specific resources that need them.

| Tag | Value | On | Why |
|---|---|---|---|
| `kubernetes.io/role/elb` | `1` | public subnets | tells the AWS cloud provider where to place **internet-facing** load balancers (the NLB for Nginx Ingress) |
| `kubernetes.io/role/internal-elb` | `1` | private subnets | where to place **internal** load balancers |
| `k8s.io/cluster-autoscaler/enabled` | `true` | node ASG | marks the ASG as autoscaler-managed |
| `k8s.io/cluster-autoscaler/maxweather-prod-eks` | `owned` | node ASG | ties the ASG to this specific cluster for auto-discovery |

---

## Rules when adding a resource
1. Build the name from `var.name_prefix` — never hardcode `maxweather` or `prod`.
2. Add `Name` and `Component` tags; let `default_tags` supply the identity tags.
3. If the module is new, add its `Component` value to the [taxonomy](#component-taxonomy) and this doc.
4. Only add functional tags on the resources that actually need them.
5. Log groups use the `/aws/<service>/...` path form.
