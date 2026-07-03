output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public (internet-facing) subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private (node/pod) subnets."
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL for the app image."
  value       = module.ecr.repository_url
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_autoscaler_role_arn" {
  description = "IRSA role ARN for the Cluster Autoscaler (used in k8s phase)."
  value       = module.eks.cluster_autoscaler_role_arn
}

output "cognito_token_endpoint" {
  description = "OAuth2 token endpoint (client_credentials)."
  value       = module.cognito.token_endpoint
}

output "cognito_client_id" {
  description = "OAuth2 client ID."
  value       = module.cognito.client_id
}

output "cognito_scope" {
  description = "OAuth2 scope required by the API."
  value       = module.cognito.scope
}

output "cognito_issuer" {
  description = "JWT issuer URL (for the Lambda authorizer)."
  value       = module.cognito.issuer
}
