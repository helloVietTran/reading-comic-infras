variable "rds_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "rds_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the ALB"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "jwt_secret_key" {
  type        = string
  sensitive = true
}

variable "brevo_api_key" {
  type        = string
  sensitive = true
}

variable "cloudinary_api_key" {
  type        = string
  sensitive = true
}

variable "cloudinary_api_secret" {
  type        = string
  sensitive = true
}

variable "cloudinary_cloud_name" {
  type        = string
  sensitive = true
}

variable "frontend_url" {
  type        = string
}

variable "container_image" {
  description = "ECR image used by the ECS task"
  type        = string
}