locals {
  common_tags = {
    Environment = "prod"
    Terraform  = "true"
    Owner       = "Tran Viet Anh"
    Project     = "do-an-tot-nghiep"
  }
  project_name = "do-an-tot-nghiep"
  repository_name = "humg/tranvietanh"
  bucket_name = "do-an-tot-nghiep-storage"
}