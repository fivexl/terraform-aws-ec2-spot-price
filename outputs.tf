locals {
  price_per_unit_list = values(local.price_per_unit_map)
  price_current_optimal = max([
    for az in var.availability_zones_names_list : min([
      for key in keys(local.price_per_unit_map) : lookup(local.price_per_unit_map, key) if split("/", key)[0] == az
    ]...)
  ]...)
  price_current_min = min(local.price_per_unit_list...)
  price_current_max = max(local.price_per_unit_list...)
}

output "spot_price_current_max" {
  description = "Maximum current Spot Price, which allows to run all Instance Types in all AZ. Maximum stability."
  value       = ceil(tonumber(format("%f", local.price_current_max)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_current_max_mod" {
  description = "Modified maximum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = ceil(tonumber(format("%f", local.price_current_max)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_current_min" {
  description = "Minimum current Spot Price, which allows to run at least one Instance Type in at least one AZ. Lowest price."
  value       = ceil(tonumber(format("%f", local.price_current_min)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_current_min_mod" {
  description = "Modified minimum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = ceil(tonumber(format("%f", local.price_current_min)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_current_optimal" {
  description = "Optimal current Spot Price, which allows to run at least one Instance Type in all AZ. Balance between stability and costs."
  value       = ceil(tonumber(format("%f", local.price_current_optimal)) * var.normalization_modifier) / var.normalization_modifier
}

output "spot_price_current_optimal_mod" {
  description = "Modified optimal current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply."
  value       = ceil(tonumber(format("%f", local.price_current_optimal)) * var.custom_price_modifier * var.normalization_modifier) / var.normalization_modifier
}
