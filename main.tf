locals {
  instance_types_weighted_map = length(var.instance_types_list) != 0 ? [for type in var.instance_types_list : { instance_type = type, weighted_capacity = var.instance_weight_default }] : var.instance_types_weighted_map
  azs_instances_weights       = { for pair in setproduct(var.availability_zones_names_list, local.instance_types_weighted_map) : "${pair[0]}/${pair[1].instance_type}" => pair[1].weighted_capacity }
}

data "aws_ec2_spot_price" "this" {
  for_each          = local.azs_instances_weights
  availability_zone = split("/", each.key)[0]
  instance_type     = split("/", each.key)[1]
  filter {
    name   = "product-description"
    values = var.product_description_list
  }
}

locals {
  price_per_unit_map = { for item in data.aws_ec2_spot_price.this : "${item.availability_zone}/${item.instance_type}" => tonumber(item.spot_price) / tonumber(lookup(local.azs_instances_weights, "${item.availability_zone}/${item.instance_type}", var.instance_weight_default)) }
}
