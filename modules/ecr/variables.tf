variable "project_name" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = false
}

variable "max_image_count" {
  type    = number
  default = 10
}

variable "tags" {
  type = map(string)
}