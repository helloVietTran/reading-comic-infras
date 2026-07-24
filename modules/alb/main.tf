resource "aws_lb" "this" {

  name = "${var.project_name}-alb"

  internal           = false
  load_balancer_type = "application"

  security_groups = var.security_group_ids

  subnets = var.public_subnet_ids

  ip_address_type = "ipv4"

  enable_deletion_protection = false

  idle_timeout = 60

  enable_http2 = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

resource "aws_lb_target_group" "this" {

  name = "${var.project_name}-target-group"

  port = var.target_port

  protocol = "HTTP"

  protocol_version = "HTTP1"

  target_type = "ip"

  vpc_id = var.vpc_id

  ip_address_type = "ipv4"

  health_check {

    enabled = true

    protocol = "HTTP"

    path = var.health_check_path

    port = "traffic-port"

    interval = 30

    timeout = 10

    healthy_threshold = 5

    unhealthy_threshold = 2

    matcher = "200"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-target-group"
  })
}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# có chứng chỉ rồi
resource "aws_lb_listener" "https" {

  load_balancer_arn = aws_lb.this.arn

  port = 443

  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"

  certificate_arn = var.certificate_arn

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-https-listener"
  })
}

