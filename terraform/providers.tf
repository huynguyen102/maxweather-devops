provider "aws" {
  region = var.region

  # Applied to every resource in the root and all child modules. Modules add only
  # a per-resource Component tag on top of these; they never re-declare identity tags.
  default_tags {
    tags = local.common_tags
  }
}
