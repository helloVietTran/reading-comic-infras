resource "aws_cloudwatch_log_group" "this" {

  name              = var.log_group_name
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = var.log_group_name
  })
}

resource "aws_ecs_task_definition" "this" {

  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([

    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      cpu    = var.container_cpu
      memory = var.container_memory

      portMappings = [
        {
          name          = "${var.container_name}-8080"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      restartPolicy = {
        enabled              = true
        restartAttemptPeriod = 300
      }

      environment = [
        {
          name  = "FRONTEND_URL"
          value = var.frontend_url
        },

      ]

      secrets = [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${var.application_secret_arn}:POSTGRES_PASSWORD::"
        },
        {
          name      = "POSTGRES_USER"
          valueFrom = "${var.application_secret_arn}:POSTGRES_USER::"
        },
        {
          name      = "POSTGRES_URL"
          valueFrom = "${var.application_secret_arn}:POSTGRES_URL::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${var.application_secret_arn}:JWT_SECRET_KEY::"
        },
        {
          name      = "REDIS_HOST"
          valueFrom = "${var.application_secret_arn}:REDIS_HOST::"
        },
        {
          name      = "REDIS_PORT"
          valueFrom = "${var.application_secret_arn}:REDIS_PORT::"
        },

        {
          name      = "BREVO_API_KEY"
          valueFrom = "${var.application_secret_arn}:BREVO_API_KEY::"
        },

        {
          name      = "CLOUDINARY_API_SECRET"
          valueFrom = "${var.application_secret_arn}:CLOUDINARY_API_SECRET::"
        },
        {
          name      = "CLOUDINARY_CLOUD_NAME"
          valueFrom = "${var.application_secret_arn}:CLOUDINARY_CLOUD_NAME::"
        },
         {
          name      = "CLOUDINARY_API_KEY"
          valueFrom = "${var.application_secret_arn}:CLOUDINARY_API_KEY::"
        }
      ]

      logConfiguration = {

        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },

    {
      name      = "aws-otel-collector"
      image     = "public.ecr.aws/aws-observability/aws-otel-collector:v0.49.0"
      essential = true
      cpu       = 0

      command = [
        "--config=/etc/ecs/ecs-cloudwatch-xray.yaml"
      ]

      logConfiguration = {

        logDriver = "awslogs"

        options = {
          awslogs-group         = "/ecs/ecs-aws-otel-sidecar-collector"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          mode                  = "non-blocking"
          max-buffer-size       = "25m"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project_name}-task-definition"
  })
}
