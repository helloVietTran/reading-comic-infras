# IaC Backend

## Cấu trúc
- environments/prod: triển khai môi trường production
- modules/: các module Terraform (network, rds, redis, alb, iam, ecs, secrets)

## Biến môi trường / tfvars cần cấu hình
Cập nhật file `environments/prod/terraform.tfvars` với:
- `rds_username`: tài khoản PostgreSQL
- `rds_password`: mật khẩu RDS
- `certificate_arn`: ARN certificate ALB (cần tạo thủ công trên aws bằng domain của bản thân)
- `jwt_secret_key`: secret JWT
- `brevo_api_key`: API key Brevo
- `cloudinary_api_key`, `cloudinary_api_secret`, `cloudinary_cloud_name`
- `aws_region`: ví dụ `ap-southeast-2`
- `frontend_url`: URL frontend
- `container_image`: image Docker ECR để ECS chạy, ví dụ `495199591817.dkr.ecr.ap-southeast-2.amazonaws.com/humg/vietanh:tag`

## Apply Terraform
```bash
cd IaC/backend/environments/prod
terraform init
terraform plan
terraform apply -auto-approve
```

## Lưu ý
- Không commit secret thật vào Git; nên dùng `.tfvars` local hoặc CI variables.
- Cần AWS credentials hợp lệ (`aws configure` hoặc export AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY).
- Sau khi apply, kiểm tra ECS service, ALB, RDS, Redis, Secret Manager.
- Nếu đổi image, chỉ cần cập nhật `container_image` và chạy `terraform apply`.
