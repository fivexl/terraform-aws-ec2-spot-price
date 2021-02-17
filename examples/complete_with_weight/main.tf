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
  instance_types_weighted_map = [
    { instance_type = "c5.2xlarge", weighted_capacity = "2" },
    { instance_type = "c5.4xlarge", weighted_capacity = "4" },
    { instance_type = "c5.4xlarge", weighted_capacity = "12" },
    { instance_type = "c5a.2xlarge", weighted_capacity = "2" },
    { instance_type = "c5a.4xlarge", weighted_capacity = "4" },
    { instance_type = "c5a.4xlarge", weighted_capacity = "12" }
  ]
  product_description_list = ["Linux/UNIX", "Linux/UNIX (Amazon VPC)"]
  custom_price_modifier    = 1.03
  normalization_modifier   = 1000
}

output "spot_price_current_max" {
  value = module.spot-price.spot_price_current_max
}

output "spot_price_current_max_mod" {
  value = module.spot-price.spot_price_current_max_mod
}

output "spot_price_current_min" {
  value = module.spot-price.spot_price_current_min
}

output "spot_price_current_min_mod" {
  value = module.spot-price.spot_price_current_min_mod
}

output "spot_price_current_optimal" {
  value = module.spot-price.spot_price_current_optimal
}

output "spot_price_current_optimal_mod" {
  value = module.spot-price.spot_price_current_optimal_mod
}