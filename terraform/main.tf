# Root module: wires the building blocks together and passes the naming prefix down.
# Modules are added here phase by phase (vpc → ecr → eks → cognito → authorizer →
# api-gateway → cloudwatch).

module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway
}
