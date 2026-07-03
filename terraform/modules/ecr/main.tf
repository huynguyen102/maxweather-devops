# Container registry for the app image. CI/CD pushes here; EKS pulls from here.
# Immutable tags + scan-on-push are the two security defaults; a lifecycle policy
# keeps storage (and cost) bounded by expiring old images.

locals {
  component = "registry"
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.name_prefix}-app"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name      = "${var.name_prefix}-app"
    Component = local.component
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the most recent ${var.max_image_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.max_image_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}
