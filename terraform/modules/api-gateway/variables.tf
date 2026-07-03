variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "authorizer_invoke_arn" {
  description = "Invoke ARN of the Lambda authorizer."
  type        = string
}

variable "authorizer_function_name" {
  description = "Name of the Lambda authorizer (for the invoke permission)."
  type        = string
}

variable "backend_url" {
  description = "Backend the API proxies to — the Nginx Ingress NLB URL. Set after the cluster is up (phase 8)."
  type        = string
  default     = ""
}

variable "authorizer_cache_ttl" {
  description = "Seconds to cache an authorizer result per token, reducing Lambda calls (0 disables)."
  type        = number
  default     = 300
}

variable "stage_name" {
  description = "API stage name. $default gives a stageless invoke URL."
  type        = string
  default     = "$default"
}

variable "log_retention_days" {
  description = "CloudWatch retention for API access logs."
  type        = number
  default     = 14
}
