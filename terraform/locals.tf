locals {
  # Single home for the naming convention: {project}-{environment}. Every module
  # receives this prefix and builds resource names from it.
  name_prefix = "${var.project}-${var.environment}"

  # Identity tags applied to all resources via the provider's default_tags.
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "huy.devops.engineer@gmail.com"
  }
}
