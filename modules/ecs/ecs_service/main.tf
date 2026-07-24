resource "aws_ecs_service" "this" {

  name    = "${var.project_name}-service"
  cluster = var.cluster_arn

  task_definition = var.task_definition_arn

  desired_count = var.desired_count
  
  platform_version = "1.4.0"

  scheduling_strategy = "REPLICA"

  enable_execute_command = true

  enable_ecs_managed_tags = true

  propagate_tags = "NONE"

  health_check_grace_period_seconds = 60

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {

    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {

    target_group_arn = var.target_group_arn

    container_name = var.container_name

    container_port = 8080
  }

  capacity_provider_strategy {

    capacity_provider = "FARGATE"

    weight = 1

    base = 0
  }

  depends_on = [
    var.listener_arn
  ]

  tags = merge(var.tags, {
    Name = "${var.project_name}-service"
  })
}

############################################
# ECS Auto Scaling Target
############################################

resource "aws_appautoscaling_target" "this" {

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  resource_id = "service/${var.cluster_name}/${aws_ecs_service.this.name}"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

############################################
# CPU Auto Scaling Policy
############################################

resource "aws_appautoscaling_policy" "cpu" {

  name = "${var.project_name}-cpu-scaling"

  policy_type = "TargetTrackingScaling"

  service_namespace  = aws_appautoscaling_target.this.service_namespace
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  resource_id        = aws_appautoscaling_target.this.resource_id

  target_tracking_scaling_policy_configuration {

    target_value = var.cpu_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}

############################################
# Memory Auto Scaling Policy
############################################

resource "aws_appautoscaling_policy" "memory" {

  name = "${var.project_name}-memory-scaling"

  policy_type = "TargetTrackingScaling"

  service_namespace  = aws_appautoscaling_target.this.service_namespace
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  resource_id        = aws_appautoscaling_target.this.resource_id

  target_tracking_scaling_policy_configuration {

    target_value = var.memory_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}