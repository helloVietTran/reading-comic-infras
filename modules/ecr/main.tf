resource "aws_ecr_repository" "this" {

  name = "${var.project_name}/${var.repository_name}"

  image_tag_mutability = "MUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "v-*"
  }

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecr"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {

  repository = aws_ecr_repository.this.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep only last ${var.max_image_count} images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = var.max_image_count
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}