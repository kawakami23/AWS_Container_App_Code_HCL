########################
# RDS
########################

# Define RDS subnet group
resource "aws_db_subnet_group" "main" {
  name       = "${var.common.env}-rds-subnet-group"
  subnet_ids = var.network.private_subnet_for_db_ids
}

# Define RDS parameter group
resource "aws_db_parameter_group" "main" {
  name   = "${var.common.env}-mysql-param"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# Define RDS instance
resource "aws_db_instance" "main" {
  identifier                = "${var.common.env}-db-mysql"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.small"
  multi_az                  = false
  db_name                   = var.db_info.name
  username                  = var.db_info.db_master_user_name
  password                  = var.db_info.db_master_user_password
  parameter_group_name      = aws_db_parameter_group.main.name
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [var.network.security_group_for_db_id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}