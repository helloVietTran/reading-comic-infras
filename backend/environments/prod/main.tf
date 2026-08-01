module "network" {

  source = "../../modules/network"

  project_name = local.project_name

  vpc_cidr = "10.0.0.0/24"

  public_subnets = {

    public_1 = {
      cidr = "10.0.0.0/28"
      az   = "ap-southeast-2a"
      name = "public-subnet-1"
    }

    public_2 = {
      cidr = "10.0.0.64/28"
      az   = "ap-southeast-2b"
      name = "public-subnet-2"
    }
  }

  private_subnets = {

    app_1 = {
      cidr = "10.0.0.16/28"
      az   = "ap-southeast-2a"
      name = "private-subnet-ecs"
    }

    db_1 = {
      cidr = "10.0.0.32/28"
      az   = "ap-southeast-2a"
      name = "private-subnet-database-1"
    }

    db_2 = {
      cidr = "10.0.0.48/28"
      az   = "ap-southeast-2b"
      name = "private-subnet-database-2"
    }
  }


  tags = local.common_tags
}

module "security_groups" {

  source = "../../modules/security_groups"

  project_name = local.project_name

  vpc_id = module.network.vpc_id

  tags = local.common_tags
}

module "rds" {

  source = "../../modules/rds"

  project_name = local.project_name

  db_name  = "reading_comic"
  username = var.rds_username
  password = var.rds_password

  db_subnet_group_name = module.network.db_subnet_group_name

  vpc_security_group_ids = [
    module.security_groups.rds_sg_id
  ]

  tags = local.common_tags
}

module "elasticache" {

  source = "../../modules/elasticache"

  project_name = local.project_name

  subnet_group_name = module.network.elasticache_subnet_group_name

  security_group_ids = [
    module.security_groups.redis_sg_id
  ]

  tags = local.common_tags
}

module "ecr" {

  source = "../../modules/ecr"

  project_name = local.project_name

  repository_name = local.repository_name

  image_tag_mutability = "MUTABLE"

  scan_on_push = false

  max_image_count = 10

  tags = local.common_tags
}

module "alb" {

  source = "../../modules/alb"

  project_name = local.project_name

  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids

  security_group_ids = [
    module.security_groups.alb_sg_id
  ]

  certificate_arn = var.certificate_arn

  target_port = 8080

  health_check_path = "/api/actuator/health"

  tags = local.common_tags
}

module "iam" {

  source = "../../modules/iam"

  project_name = local.project_name

  bucket_name = local.bucket_name
  application_secret_arn = module.secrets_manager.application_secret_arn

  tags = local.common_tags
}


module "secrets_manager" {

  source = "../../modules/secrets_manager"

  project_name = local.project_name

  postgres_password = var.rds_password
  postgres_user = var.rds_username

  jwt_secret_key = var.jwt_secret_key

  brevo_api_key = var.brevo_api_key

  cloudinary_api_secret = var.cloudinary_api_secret
  cloudinary_api_key = var.cloudinary_api_key
  cloudinary_cloud_name = var.cloudinary_cloud_name

  redis_host = module.elasticache.configuration_endpoint
  redis_port = module.elasticache.redis_port
  postgres_url = "jdbc:postgresql://${module.rds.db_address}:${module.rds.db_port}/${module.rds.db_name}?sslmode=require"

  tags = local.common_tags
}

module "ecs_cluster" {
  source = "../../modules/ecs/ecs_cluster"

  project_name = local.project_name

  enable_container_insights = false

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  tags = local.common_tags
}

module "ecs_task" {
  source = "../../modules/ecs/ecs_task"

  project_name = local.project_name

  # task defination
  container_name = "${local.project_name}-app"
  # inject from gitlab-ci
  container_image = var.container_image

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  application_secret_arn = module.secrets_manager.application_secret_arn

  frontend_url = var.frontend_url

  aws_region = var.aws_region

  log_group_name = "/ecs/${local.project_name}"

  # service

  tags = local.common_tags
}

module "ecs_service" {

  source = "../../modules/ecs/ecs_service"

  project_name = local.project_name

  cluster_name = module.ecs_cluster.cluster_name
  cluster_arn         = module.ecs_cluster.cluster_arn
  task_definition_arn = module.ecs_task.task_definition_arn

  target_group_arn = module.alb.target_group_arn
  listener_arn     = module.alb.https_listener_arn

  private_subnet_ids = [
    module.network.ecs_subnet_id
  ]

  ecs_security_group_id = module.security_groups.ecs_sg_id

  container_name = "${local.project_name}-app"

  desired_count = 1

  tags = local.common_tags
}