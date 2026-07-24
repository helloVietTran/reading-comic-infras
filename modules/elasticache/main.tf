resource "aws_elasticache_replication_group" "redis" {

  replication_group_id = "${var.project_name}-redis"

  description = "Redis Cluster"

  engine = "redis"

  node_type = "cache.r7g.large"

  port = 6379

  parameter_group_name = "default.redis7.cluster.on"

  subnet_group_name = var.subnet_group_name

  security_group_ids = var.security_group_ids

  ####################################################
  # Cluster Mode
  ####################################################

  num_node_groups         = 1
  replicas_per_node_group = 1

  ####################################################
  # High Availability
  ####################################################

  automatic_failover_enabled = true

  multi_az_enabled = true

  ####################################################
  # Encryption
  ####################################################

  transit_encryption_enabled = true

  at_rest_encryption_enabled = true

  ####################################################
  # Backup
  ####################################################

  snapshot_retention_limit = 1

  snapshot_window = "14:00-15:00"

  ####################################################
  # Maintenance
  ####################################################

  auto_minor_version_upgrade = true

  ####################################################
  # Apply
  ####################################################

  apply_immediately = true

  ####################################################
  # Tags
  ####################################################

  tags = merge(var.tags, {
    Name = "${var.project_name}-redis"
    Type = "ElasticCache"
  })
}