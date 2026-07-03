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

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
}

module "eks" {
  source = "./modules/eks"

  name_prefix            = local.name_prefix
  cluster_version        = var.cluster_version
  subnet_ids             = module.vpc.private_subnet_ids
  node_instance_types    = var.node_instance_types
  node_desired_size      = var.node_desired_size
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  endpoint_public_access = var.eks_endpoint_public_access
  public_access_cidrs    = var.eks_public_access_cidrs
}

module "cognito" {
  source = "./modules/cognito"

  name_prefix = local.name_prefix
}

module "lambda_authorizer" {
  source = "./modules/lambda-authorizer"

  name_prefix    = local.name_prefix
  issuer         = module.cognito.issuer
  jwks_uri       = module.cognito.jwks_uri
  audience       = module.cognito.client_id
  required_scope = module.cognito.scope
}

module "api_gateway" {
  source = "./modules/api-gateway"

  name_prefix              = local.name_prefix
  authorizer_invoke_arn    = module.lambda_authorizer.invoke_arn
  authorizer_function_name = module.lambda_authorizer.function_name
  backend_url              = var.api_backend_url
}
