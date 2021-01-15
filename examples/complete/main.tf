provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs_max  = 3
  azs_list = slice(data.aws_availability_zones.available.names, 0, tonumber(local.azs_max))
}

module "spot-price" {
  source                        = "../../"
  availability_zones_names_list = local.azs_list
  instance_type                 = "c5.4xlarge"
  custom_max_price_modifier     = 1.03
}

output "spot_price_min" {
  value = module.spot-price.spot_price_min
}

output "spot_price_max" {
  value = module.spot-price.spot_price_max
}

output "spot_price_over" {
  value = module.spot-price.spot_price_over
}

output "spot_price_avg" {
  value = module.spot-price.spot_price_avg
}