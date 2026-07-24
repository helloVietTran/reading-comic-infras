resource "aws_db_instance" "postgres" {

  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "15.18"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  # specify IOPS or storage throughput for engine postgres and a storage size more than 400.
  # iops               = 3000
  # storage_throughput = 125

  db_name  = var.db_name
  username = var.username
  password = var.password

  port = 5432

  multi_az = true

  publicly_accessible = false

  storage_encrypted = true

  backup_retention_period = 1
  backup_window           = "00:00-00:30"

  maintenance_window = "sat:15:14-sat:15:44"

  auto_minor_version_upgrade = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]

  parameter_group_name = "default.postgres15"

  db_subnet_group_name = var.db_subnet_group_name

  vpc_security_group_ids = var.vpc_security_group_ids

  deletion_protection = false

  copy_tags_to_snapshot = true

  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-postgres"
    Type = "RDS"
  })
}