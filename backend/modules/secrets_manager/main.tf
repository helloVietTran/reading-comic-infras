resource "aws_secretsmanager_secret" "application" {

  name = "${var.project_name}/application"

  description = "Application secrets"

  tags = merge(var.tags, {
    Name = "${var.project_name}-application-secret"
  })
}

resource "aws_secretsmanager_secret_version" "application" {

  secret_id = aws_secretsmanager_secret.application.id

  secret_string = jsonencode({

    JWT_SECRET_KEY        = var.jwt_secret_key
    BREVO_API_KEY         = var.brevo_api_key

    CLOUDINARY_CLOUD_NAME = var.cloudinary_cloud_name
    CLOUDINARY_API_SECRET = var.cloudinary_api_secret
    CLOUDINARY_API_KEY    = var.cloudinary_api_key

    REDIS_PORT            = var.redis_port
    REDIS_HOST            = var.redis_host

    POSTGRES_USER         = var.postgres_user
    POSTGRES_PASSWORD     = var.postgres_password
    POSTGRES_URL          = var.postgres_url
  })
}