locals {
  price_per_unit_list = values(local.price_per_unit_map)
  price_at_least_one_type_per_az = max([
    for az in var.availability_zones_names_list : min([
      for key in keys(local.price_per_unit_map) : lookup(local.price_per_unit_map, key) if split("/", key)[0] == az
    ]...)
  ]...)
  price_min = min(local.price_per_unit_list...)
  price_max = max(local.price_per_unit_list...)
}

# Normalized prices
output "spot_price_at_least_one_type_per_az" {
  description = "At least one type per each AZ. This behavior guarantees start a least ONE instance type in all AZ. Combined with WeightedCapacity will give the most optimal solution."
  value       = ceil(tonumber(format("%f", local.price_at_least_one_type_per_az)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_at_least_one_type_per_az_over" {
  description = "At least one type per each AZ with an additional improvement. This behavior guarantees start a least ONE instance type in all AZ. Combined with WeightedCapacity will give the most optimal solution and also add stability in the event of price increases and frequent demand."
  value       = ceil(tonumber(format("%f", local.price_at_least_one_type_per_az)) * var.custom_max_price_modifier * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_all_types_all_az" {
  description = "Launch all and everywhere. This behavior guarantees start all instance types in all AZ. This is the maximum price from the list of spot prices."
  value       = ceil(tonumber(format("%f", local.price_max)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_all_types_all_az_over" {
  description = "Launch all and everywhere with an additional improvement. The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand."
  value       = ceil(tonumber(format("%f", local.price_max)) * var.custom_max_price_modifier * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_cheapest" {
  description = "Launch with lowest possible price. This behavior NOT guarantee to run in all AZ. Only one most profitable instance type will be launched in the most profitable AZ."
  value       = ceil(tonumber(format("%f", local.price_min)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_avg" {
  description = "(Deprecated) Average price within all AZ and types. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price."
  value       = ceil(tonumber(format("%f", sum(local.price_per_unit_list) / length(local.price_per_unit_list))) * var.normalization_modifier) / var.normalization_modifier
}

# RAW prices without normalization
output "spot_price_at_least_one_type_per_az_raw" {
  description = "Raw (without normalization) At least one type per each AZ. This behavior guarantees start a least ONE instance type in all AZ. Combined with WeightedCapacity will give the most optimal solution."
  value       = ceil(tonumber(format("%f", local.price_at_least_one_type_per_az)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_at_least_one_type_per_az_over_raw" {
  description = "Raw (without normalization) At least one type per each AZ with an additional improvement. This behavior guarantees start a least ONE instance type in all AZ. Combined with WeightedCapacity will give the most optimal solution and also add stability in the event of price increases and frequent demand."
  value       = ceil(tonumber(format("%f", local.price_at_least_one_type_per_az)) * var.custom_max_price_modifier * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_all_types_all_az_raw" {
  description = "Raw (without normalization) Launch all and everywhere. This behavior guarantees start all instance types in all AZ. This is the maximum price from the list of spot prices."
  value       = tonumber(format("%f", local.price_max))
}

output "spot_price_all_types_all_az_over_raw" {
  description = "Raw (without normalization) Launch all and everywhere with an additional improvement. The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand."
  value       = tonumber(format("%f", local.price_max)) * var.custom_max_price_modifier
}

output "spot_price_cheapest_raw" {
  description = "Raw (without normalization) Launch with lowest possible price. This behavior NOT guarantee to run in all AZ. Only one most profitable instance type will be launched in the most profitable AZ."
  value       = tonumber(format("%f", local.price_min))
}

output "spot_price_avg_raw" {
  description = "(Deprecated) Raw (without normalization) Average price within all AZ and types. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price."
  value       = tonumber(format("%f", sum(local.price_per_unit_list) / length(local.price_per_unit_list)))
}