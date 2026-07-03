output "repository_url" {
  description = "Repository URL to push to (CI) and pull from (EKS)."
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ARN of the repository (for IAM policies)."
  value       = aws_ecr_repository.app.arn
}

output "repository_name" {
  description = "Name of the repository."
  value       = aws_ecr_repository.app.name
}
