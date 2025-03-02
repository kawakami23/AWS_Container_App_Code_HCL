terraform {
  required_version = ">=1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.81.0"
    }
  }
  backend "s3" {
    encrypt = true
  }
}

# module "network" {
#   source  = "../../modules/network"
#   common  = local.common
#   network = local.network
#   public_hosted_zone = var.public_hosted_zone
# }

# module "ec2" {
#   source  = "../../modules/ec2"
#   common  = local.common
#   network = module.network
# }

# module "ecr" {
#   source = "../../modules/ecr"
#   common = local.common
# }

# module "alb_internal" {
#   source  = "../../modules/alb_internal"
#   common  = local.common
#   network = module.network
# }

# module "ecs_backend" {
#   source          = "../../modules/ecs_backend"
#   common          = local.common
#   github_actions  = var.github_actions
#   network         = module.network
#   alb_internal    = module.alb_internal
#   secrets_manager = module.secrets_manager
#   repository      = module.ecr.backend_repository_arn
# }

# module "alb_ingress" {
#   source  = "../../modules/alb_ingress"
#   common  = local.common
#   network = module.network
# }

# module "ecs_frontend" {
#   source          = "../../modules/ecs_frontend"
#   common          = local.common
#   network         = module.network
#   alb_ingress     = module.alb_ingress
#   alb_internal    = module.alb_internal
#   secrets_manager = module.secrets_manager
# }

# module "rds" {
#   source  = "../../modules/rds"
#   common  = local.common
#   db_info = var.db
#   network = module.network
# }

# module "secrets_manager" {
#   source  = "../../modules/secrets_manager"
#   common  = local.common
#   db_info = var.db
#   rds     = module.rds
# }

module "cicd" {
  source          = "../../modules/cicd"
  common          = local.common
  code_connection = var.code_connection
}