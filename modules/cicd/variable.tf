variable "common" {
  type = object({
    env       = string
    region    = string
    account_id = string
  })
}

variable "code_connection" {
  type = object({
    arn = string
  })
}
