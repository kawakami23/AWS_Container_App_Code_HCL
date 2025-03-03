data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  common = {
    env = "cntr-app-code"
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    }
  
  network = {
    cidr = "172.16.0.0/16"
    public_subnets_for_ingress = [ 
      {
          az = "a"
          cidr = "172.16.0.0/24"
      },
      {
          az = "c"
          cidr = "172.16.1.0/24"
      }
    ]
    private_subnets_for_container = [
      {
          az = "a"
          cidr = "172.16.10.0/24"
      },
      {
          az = "c"
          cidr = "172.16.11.0/24"
      }
    ]
    private_subnets_for_db = [
      {
          az = "a"
          cidr = "172.16.20.0/24"
      },
      {
          az = "c"
          cidr = "172.16.21.0/24"
      }
    ]
    private_subnets_for_management = [
      {
          az = "a"
          cidr = "172.16.240.0/24"
      }
    ]
    private_subnets_for_vpn = [
      {
          az = "a"
          cidr = "172.16.242.0/24"
      }
    ]
    client_vpn_cidr = "172.17.0.0/22"
  }  
}