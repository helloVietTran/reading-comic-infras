resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend"
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]
}

output "frontend_website_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

# disable cloudfront util your account become verified
# resource "aws_cloudfront_origin_access_control" "frontend" {

#   name                              = "${var.project_name}-oac"
#   description                       = "OAC for frontend"
#   origin_access_control_origin_type = "s3"
#   signing_behavior = "always"
#   signing_protocol = "sigv4"

# }

# resource "aws_cloudfront_distribution" "frontend" {
#   enabled = true
#   default_root_object = "index.html"

#   aliases = [
#     var.domain_name
#   ]

#   origin {
#     domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
#     origin_id = "frontend"
#     origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
#   }

#   default_cache_behavior {
#     target_origin_id = "frontend"
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods = [
#       "GET",
#       "HEAD"
#     ]

#     cached_methods = [
#       "GET",
#       "HEAD"
#     ]

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"

#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
#   # SPA Routing
#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#   }

#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#   }
# }

# resource "aws_s3_bucket_policy" "frontend" {

#   bucket = aws_s3_bucket.frontend.id

#   policy = jsonencode({

#     Version = "2012-10-17"

#     Statement = [
#       {
#         Sid    = "AllowCloudFront"
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudfront.amazonaws.com"
#         }
#         Action = "s3:GetObject"

#         Resource = "${aws_s3_bucket.frontend.arn}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
#           }
#         }
#       }
#     ]
#   })
# }
