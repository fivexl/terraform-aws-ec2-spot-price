locals {
  project_name       = lower("spot_price")
  vpc_cidr           = "10.68.0.0/16" # 10.68.0.1 - 10.68.255.254
  vpc_azs_max        = 3
  vpc_azs_list       = slice(data.aws_availability_zones.available.names, 0, tonumber(local.vpc_azs_max))
  vpc_public_subnets = ["10.68.32.0/19", "10.68.64.0/19", "10.68.96.0/19"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source                         = "terraform-aws-modules/vpc/aws"
  version                        = "2.70.0"
  name                           = local.project_name
  cidr                           = local.vpc_cidr
  azs                            = local.vpc_azs_list
  public_subnets                 = local.vpc_public_subnets
  manage_default_security_group  = true
  default_security_group_name    = "default-${local.project_name}"
  default_security_group_ingress = []
  default_security_group_egress  = []
}