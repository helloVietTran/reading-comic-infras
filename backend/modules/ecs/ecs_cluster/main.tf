resource "aws_ecs_cluster" "this" {

  name = "${var.project_name}-ecs-cluster"

  dynamic "setting" {

    for_each = var.enable_container_insights ? [1] : []

    content {

      name  = "containerInsights"

      value = "enabled"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecs-cluster"
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {

  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers
}