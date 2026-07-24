variable "project_name" {
  description = "Project name"
  type        = string
}

variable "jwt_secret_key" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "brevo_api_key" {
  description = "Brevo API key"
  type        = string
  sensitive   = true
}

variable "cloudinary_cloud_name" {
  description = "Cloudinary cloud name"
  type        = string
}

variable "cloudinary_api_key" {
  description = "Cloudinary API key"
  type        = string
  sensitive   = true
}

variable "cloudinary_api_secret" {
  description = "Cloudinary API secret"
  type        = string
  sensitive   = true
}

variable "redis_host" {
  description = "Redis endpoint"
  type        = string
  sensitive = true
}

variable "redis_port" {
  description = "Redis port"
  type        = string
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_url" {
  description = "PostgreSQL JDBC URL"
  type        = string
  sensitive = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}