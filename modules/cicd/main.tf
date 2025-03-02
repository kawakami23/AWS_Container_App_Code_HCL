########################
# CodeConnections
########################

data "aws_codestarconnections_connection" "example" {
  arn = var.code_connection.arn
}

