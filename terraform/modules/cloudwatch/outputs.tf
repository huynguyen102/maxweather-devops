output "application_log_group" {
  description = "CloudWatch log group that receives application (pod stdout) logs."
  value       = "/aws/containerinsights/${var.cluster_name}/application"
}
