variable "project_name" {
  type = string
}

variable "enable_container_insights" {
  type    = bool
  default = false
}

variable "capacity_providers" {
  type = list(string)

  default = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
}

variable "tags" {
  type = map(string)
}
