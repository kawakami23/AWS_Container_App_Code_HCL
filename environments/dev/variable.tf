variable "db" {
  type = object({
    name                    = string
    db_master_user_name     = string
    db_master_user_password = string
    db_user_name            = string
    db_user_password        = string
  })
}

variable "public_hosted_zone" {
  type = object({
    domain_name = string
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
