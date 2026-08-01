variable "project_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_cpu" {
  type = number
  default = 461
}

variable "container_memory" {
  type = number
  default = 1792
}

variable "task_cpu" {
  type = number
  default = 512
}

variable "task_memory" {
  type = number
  default = 2048
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "aws_region" {
  type = string
}


variable "frontend_url" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable application_secret_arn{
  type = string
}