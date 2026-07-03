variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "issuer" {
  description = "Expected JWT issuer (Cognito user pool issuer URL)."
  type        = string
}

variable "jwks_uri" {
  description = "JWKS endpoint used to verify token signatures."
  type        = string
}

variable "audience" {
  description = "Expected client_id in the token (Cognito app client ID)."
  type        = string
}

variable "required_scope" {
  description = "OAuth2 scope the token must carry to be authorized."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention for the authorizer function."
  type        = number
  default     = 14
}
