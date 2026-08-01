resource "aws_security_group" "alb" {

  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "HTTPS"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "alb-sg"
  })
}

resource "aws_security_group" "ecs" {

  name        = "${var.project_name}-ecs-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = var.vpc_id

  ingress {

    description = "ALB to ECS"

    from_port = 8080
    to_port   = 8080

    protocol = "tcp"

    security_groups = [
      aws_security_group.alb.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(var.tags, {
    Name = "ecs-sg"
  })
}

resource "aws_security_group" "rds" {

  name        = "${var.project_name}-rds-sg"
  description = "Allow ECS connect to PostgreSQL"

  vpc_id = var.vpc_id

  ingress {

    description = "PostgreSQL"

    from_port = 5432
    to_port   = 5432

    protocol = "tcp"

    security_groups = [
      aws_security_group.ecs.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(var.tags, {
    Name = "rds-sg"
  })
}

resource "aws_security_group" "redis" {

  name        = "${var.project_name}-redis-sg"
  description = "Allow ECS connect to Redis"

  vpc_id = var.vpc_id

  ingress {

    description = "Redis"

    from_port = 6379
    to_port   = 6379

    protocol = "tcp"

    security_groups = [
      aws_security_group.ecs.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(var.tags, {
    Name = "redis-sg"
  })
}
