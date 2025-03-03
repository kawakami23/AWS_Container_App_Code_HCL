########################
# VPC
########################

# Define VPC
resource "aws_vpc" "main" {
  cidr_block           = var.network.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.common.env}-Vpc"
  }
}

########################
# Subnet
########################

# Define public subnets for ingress
resource "aws_subnet" "public_ingress" {
  for_each          = { for i, s in var.network.public_subnets_for_ingress : i => s }
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr
  tags = {
    Name = "${var.common.env}-subnet-public-ingress-1${each.value.az}"
  }
}

# Define private subnets for container application
resource "aws_subnet" "private_container" {
  for_each          = { for i, s in var.network.private_subnets_for_container : i => s }
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr
  tags = {
    Name = "${var.common.env}-subnet-private-container-1${each.value.az}"
  }
}

# Define private subnets for DB
resource "aws_subnet" "private_db" {
  for_each          = { for i, s in var.network.private_subnets_for_db : i => s }
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr
  tags = {
    Name = "${var.common.env}-subnet-private-db-1${each.value.az}"
  }
}

# Define private subnets for management
resource "aws_subnet" "private_management" {
  for_each          = { for i, s in var.network.private_subnets_for_management : i => s }
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr
  tags = {
    Name = "${var.common.env}-subnet-private-management-1${each.value.az}"
  }
}

# Define private subnets for VPN
resource "aws_subnet" "private_vpn" {
  for_each          = { for i, s in var.network.private_subnets_for_vpn : i => s }
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.common.region}${each.value.az}"
  cidr_block        = each.value.cidr
  tags = {
    Name = "${var.common.env}-subnet-private-vpn-1${each.value.az}"
  }
}

########################
# Gateway
########################

# Define Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-igw"
  }
}

# Define NAT Gateway
resource "aws_nat_gateway" "main" {
  for_each      = aws_subnet.public_ingress
  subnet_id     = each.value.id
  allocation_id = aws_eip.main[each.key].id
  tags = {
    Name = "${var.common.env}-nat-${each.key}"
  }
}

resource "aws_eip" "main" {
  for_each = aws_subnet.public_ingress
  domain   = "vpc"
}

########################
# Route Table
########################

# Define route table for public ingress
resource "aws_route_table" "public_ingress" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-rtb-public-ingress"
  }
}

resource "aws_route" "public_ingress" {
  route_table_id         = aws_route_table.public_ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_ingress" {
  for_each       = aws_subnet.public_ingress
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_ingress.id
}

# Define route table for container application
resource "aws_route_table" "private_container" {
  for_each = aws_subnet.private_container
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-rtb-private-container-${each.key}"
  }
}

resource "aws_route" "private_container" {
  for_each               = aws_route_table.private_container
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.main[each.key].id
}

resource "aws_route_table_association" "private_container" {
  for_each       = aws_subnet.private_container
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_container[each.key].id
}

# Define route table for private management
resource "aws_route_table" "private_management" {
  for_each = aws_subnet.private_management
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-rtb-private-management-${each.key}"
  }
}

resource "aws_route" "private_management" {
  for_each               = aws_route_table.private_management
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.main[each.key].id
}

resource "aws_route_table_association" "private_management" {
  for_each       = aws_subnet.private_management
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_management[each.key].id
}

########################
# Security Group
########################

# Define security group for management
resource "aws_security_group" "management" {
  name   = "${var.common.env}-sg-management"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-management"
  }
}

resource "aws_vpc_security_group_egress_rule" "management" {
  security_group_id = aws_security_group.management.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Define security group for internal ALB
resource "aws_security_group" "internal_alb" {
  name   = "${var.common.env}-sg-internal-alb"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-internal-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_frontend" {
  security_group_id = aws_security_group.internal_alb.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  referenced_security_group_id = aws_security_group.frontend.id
} 

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_management" {
  security_group_id            = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.management.id
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_management_test" {
  security_group_id            = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 10080
  to_port                      = 10080
  referenced_security_group_id = aws_security_group.management.id
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_vpn" {
  security_group_id            = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.client_vpn.id
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_vpn_test" {
  security_group_id            = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 10080
  to_port                      = 10080
  referenced_security_group_id = aws_security_group.client_vpn.id
}

resource "aws_vpc_security_group_egress_rule" "internal_alb" {
  security_group_id = aws_security_group.internal_alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Define security group for ingress ALB
resource "aws_security_group" "ingress_alb" {
  name   = "${var.common.env}-sg-ingress-alb"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-ingress-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_alb" {
  security_group_id = aws_security_group.ingress_alb.id
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_ipv4 = "0.0.0.0/0"
} 

resource "aws_vpc_security_group_egress_rule" "ingress_alb" {
  security_group_id = aws_security_group.ingress_alb.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# Define security group for frontend application
resource "aws_security_group" "frontend" {
  name = "${var.common.env}-sg-frontend"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-frontend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend" {
  security_group_id = aws_security_group.frontend.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  referenced_security_group_id = aws_security_group.ingress_alb.id
} 

resource "aws_vpc_security_group_egress_rule" "frontend" {
  security_group_id = aws_security_group.frontend.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# Define security group for backend application
resource "aws_security_group" "backend" {
  name   = "${var.common.env}-sg-backend"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-backend"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend" {
  security_group_id            = aws_security_group.backend.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.internal_alb.id
}

resource "aws_vpc_security_group_egress_rule" "backend" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Define security group for DB
resource "aws_security_group" "db" {
  name   = "${var.common.env}-sg-db"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_backend" {
  security_group_id            = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.backend.id
}

resource "aws_vpc_security_group_ingress_rule" "db_from_management" {
  security_group_id            = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.management.id
}

resource "aws_vpc_security_group_egress_rule" "db" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Define security group for client VPN
resource "aws_security_group" "client_vpn" {
  name   = "${var.common.env}-sg-client-vpn"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.common.env}-sg-client-vpn"
  }
}

resource "aws_vpc_security_group_egress_rule" "client_vpn" {
  security_group_id = aws_security_group.client_vpn.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ########################
# # Client VPN
# ########################

# # Define Client VPN endpoint
# resource "aws_ec2_client_vpn_endpoint" "main" {
#   description = "Client VPN endpoint"
#   client_cidr_block = var.network.client_vpn_cidr
#   server_certificate_arn = data.aws_acm_certificate.vpn_server.arn
#   authentication_options {
#     type = "certificate-authentication"
#     root_certificate_chain_arn = data.aws_acm_certificate.vpn_client.arn
#   }
#   connection_log_options {
#     enabled = false
#   }
#   vpc_id = aws_vpc.main.id
#   dns_servers = [cidrhost(aws_vpc.main.cidr_block, 2)]
#   split_tunnel = true
#   security_group_ids = [aws_security_group.client_vpn.id]
#   tags = {
#     Name = "${var.common.env}-client-vpn-endpoint"
#   }
# }

# # Refer to certificates pre-issued on ACM
# data "aws_acm_certificate" "vpn_server" {
#   domain = "server"
# }

# data "aws_acm_certificate" "vpn_client" {
#   domain = "client1.domain.tld"
# }

# # Associate Client VPN endpoint with target network
# resource "aws_ec2_client_vpn_network_association" "main" {
#   for_each = aws_subnet.private_vpn
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
#   subnet_id = each.value.id
# }

# # Define authorization rule for Client VPN
# resource "aws_ec2_client_vpn_authorization_rule" "main" {
#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
#   target_network_cidr = aws_vpc.main.cidr_block
#   authorize_all_groups = true
# }

########################
# Route53 Public Hosted Zone
########################

# Refer to public hosted zone
data "aws_route53_zone" "public" {
  name = var.public_hosted_zone.domain_name
}
