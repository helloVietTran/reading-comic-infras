variable "project_name" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "container_name" {
  type = string
}


variable "cluster_name" {
  type = string
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 6
}

variable "cpu_target" {
  type    = number
  default = 70
}

variable "memory_target" {
  type    = number
  default = 75
}

variable "tags" {
  type = map(string)
}

