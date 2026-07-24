##############################################
# ECS Assume Role Policy
##############################################

data "aws_iam_policy_document" "ecs_assume_role" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

##############################################
# ECS Task Execution Role
##############################################

resource "aws_iam_role" "ecs_execution_role" {

  name = "${var.project_name}-ecsTaskExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecsTaskExecutionRole"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {

  role = aws_iam_role.ecs_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################################
# ECS Task Role
##############################################

resource "aws_iam_role" "ecs_task_role" {

  name = "${var.project_name}-ecsTaskRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecsTaskRole"
  })
}

##############################################
# S3 Policy
##############################################

data "aws_iam_policy_document" "ecs_s3_policy" {

  statement {

    sid = "BucketAccess"

    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }

  statement {

    sid = "ObjectAccess"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "ecs_s3_policy" {

  name = "${var.project_name}-ecs-s3-policy"

  description = "Allow ECS Task access to S3 bucket"

  policy = data.aws_iam_policy_document.ecs_s3_policy.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecs-s3-policy"
  })
}

##############################################
# Secret Policy
##############################################

data "aws_iam_policy_document" "secret_policy" {

  statement {

    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.application_secret_arn
    ]
  }
}

resource "aws_iam_policy" "secret_policy" {

  name   = "${var.project_name}-secret-policy"

  policy = data.aws_iam_policy_document.secret_policy.json
}

##############################################
# Attach S3 Policy
##############################################

resource "aws_iam_role_policy_attachment" "ecs_task_s3_policy" {

  role = aws_iam_role.ecs_task_role.name

  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}


##############################################
# Attach Secret Policy
##############################################
resource "aws_iam_role_policy_attachment" "ecs_execution_secret_policy" {

  role = aws_iam_role.ecs_execution_role.name

  policy_arn = aws_iam_policy.secret_policy.arn
}

