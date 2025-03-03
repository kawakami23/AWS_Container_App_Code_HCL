variable "common" {
  type = object({
    env        = string
    region     = string
    account_id = string
  })
}

variable "network" {
  type = object({
    vpc_id                                  = string
    private_subnet_for_container_ids        = list(string)
    security_group_for_backend_container_id = string
  })
}

variable "alb_internal" {
  type = object({
    alb_listener_internal_prod_arn       = string
    alb_target_group_internal_blue_name  = string
    alb_target_group_internal_blue_arn   = string
    alb_listener_internal_test_arn       = string
    alb_target_group_internal_green_name = string
    alb_target_group_internal_green_arn  = string
  })
}

variable "secrets_manager" {
  type = object({
    secret_for_db_arn = string
  })
}

variable "ecr_repository" {
  type = object({
    backend_repository_uri = string
  })
}

variable "code_pipeline" {
  type = object({
    code_connection_arn = string
    artifacts_bucket_name = string
    github_repository_owner = string
    github_repository_name = string
    github_repository_branch_name = string
    docker_username = string
    docker_password = string
  })
}
