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
  product_description_list  = ["Linux/UNIX", "Linux/UNIX (Amazon VPC)"]
  custom_max_price_modifier = 1.03
  normalization_modifier    = 1000
}

output "spot_price_at_least_one_type_per_az" {
  value = module.spot-price.spot_price_at_least_one_type_per_az
}

output "spot_price_at_least_one_type_per_az_over" {
  value = module.spot-price.spot_price_at_least_one_type_per_az_over
}

output "spot_price_all_types_all_az" {
  value = module.spot-price.spot_price_all_types_all_az
}

output "spot_price_cheapest" {
  value = module.spot-price.spot_price_cheapest
}

output "spot_price_avg" {
  value = module.spot-price.spot_price_avg
}

output "spot_price_all_types_all_az_over" {
  value = module.spot-price.spot_price_all_types_all_az_over
}

output "spot_price_at_least_one_type_per_az_raw" {
  value = module.spot-price.spot_price_at_least_one_type_per_az_raw
}

output "spot_price_at_least_one_type_per_az_over_raw" {
  value = module.spot-price.spot_price_at_least_one_type_per_az_over_raw
}

output "spot_price_all_types_all_az_raw" {
  value = module.spot-price.spot_price_all_types_all_az_raw
}

output "spot_price_all_types_all_az_over_raw" {
  value = module.spot-price.spot_price_all_types_all_az_over_raw
}

output "spot_price_cheapest_raw" {
  value = module.spot-price.spot_price_cheapest_raw
}

output "spot_price_avg_raw" {
  value = module.spot-price.spot_price_avg_raw
}
