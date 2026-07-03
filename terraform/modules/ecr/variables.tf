variable "name_prefix" {
  description = "Prefix for resource names, e.g. maxweather-prod."
  type        = string
}

variable "image_tag_mutability" {
  description = "IMMUTABLE prevents overwriting a pushed tag (CI must use unique tags, e.g. git SHA); MUTABLE allows it."
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Scan images for known CVEs automatically on push."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Number of most-recent images to keep; older ones are expired by the lifecycle policy."
  type        = number
  default     = 10
}
