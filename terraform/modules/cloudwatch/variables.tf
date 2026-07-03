variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used to install the addon and name the log groups)."
  type        = string
}

variable "node_role_name" {
  description = "Worker node IAM role name; the CloudWatch agent policy is attached to it."
  type        = string
}

variable "log_retention_days" {
  description = "Retention for the Container Insights log groups."
  type        = number
  default     = 14
}
