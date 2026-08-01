variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_subnets" {

  type = map(object({
    cidr = string
    az   = string
    name = string
  }))
}

variable "private_subnets" {

  type = map(object({
    cidr = string
    az   = string
    name = string
  }))
}