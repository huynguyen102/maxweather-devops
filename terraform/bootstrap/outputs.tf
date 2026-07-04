output "state_bucket" {
  description = "S3 bucket for Terraform state."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "DynamoDB table for state locking."
  value       = aws_dynamodb_table.lock.name
}

output "ci_role_arn" {
  description = "IAM role the CI pipeline assumes via GitHub OIDC (put in the workflow)."
  value       = aws_iam_role.ci.arn
}

output "backend_config" {
  description = "Values for the main stack's backend.tf."
  value       = <<-EOT

    bucket         = "${aws_s3_bucket.state.id}"
    key            = "${var.project}/prod/terraform.tfstate"
    region         = "${var.region}"
    dynamodb_table = "${aws_dynamodb_table.lock.name}"
    encrypt        = true
  EOT
}
