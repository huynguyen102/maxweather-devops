variable "project" {
  description = "Project name; used to name the state bucket, lock table, and CI role."
  type        = string
  default     = "maxweather"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "ap-southeast-1"
}

variable "github_repo" {
  description = "GitHub repo (owner/name) allowed to assume the CI role via OIDC."
  type        = string
  default     = "huynguyen102/maxweather-devops"
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub Actions OIDC provider. Set false if the account already has one (AWS allows only one per URL)."
  type        = bool
  default     = true
}
