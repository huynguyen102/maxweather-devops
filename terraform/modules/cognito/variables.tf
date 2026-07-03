variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "scope_name" {
  description = "OAuth2 scope the API requires (granted to the machine client)."
  type        = string
  default     = "forecast.read"
}

variable "scope_description" {
  description = "Human-readable description of the scope."
  type        = string
  default     = "Read weather forecasts"
}

variable "access_token_validity_minutes" {
  description = "Lifetime of issued access tokens, in minutes."
  type        = number
  default     = 60
}

variable "domain_prefix" {
  description = "Cognito hosted-domain prefix (must be globally unique). Defaults to name_prefix."
  type        = string
  default     = ""
}
