locals {
  spot_price_list = [for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)]
}

# Normalized prices
output "spot_price_min" {
  value       = ceil(tonumber(format("%f", min(local.spot_price_list...))) * var.normalization_modifier) / var.normalization_modifier
  description = "Minimum spot price within all AZ. This behavior does not guarantee the launch of the instance in all AZ. Can be used as a way to get the lowest possible price."
}

output "spot_price_max" {
  value       = ceil(tonumber(format("%f", max(local.spot_price_list...))) * var.normalization_modifier) / var.normalization_modifier
  description = "Recommended use. Maximum spot price within all AZ. This behavior guarantees start the instance in all AZ. This is the maximum price from the list of spot prices."
}

output "spot_price_over" {
  value       = ceil(tonumber(format("%f", max(local.spot_price_list...))) * var.custom_max_price_modifier * var.normalization_modifier) / var.normalization_modifier
  description = "The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand."
}

output "spot_price_avg" {
  value       = ceil(tonumber(format("%f", sum(local.spot_price_list) / length(local.spot_price_list))) * var.normalization_modifier) / var.normalization_modifier
  description = "Average price within all AZ. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price."
}

# RAW prices without normalization
output "spot_price_min_raw" {
  value       = tonumber(format("%f", min(local.spot_price_list...)))
  description = "Raw (without normalization) Minimum spot price within all AZ. This behavior does not guarantee the launch of the instance in all AZ. Can be used as a way to get the lowest possible price."
}

output "spot_price_max_raw" {
  value       = tonumber(format("%f", max(local.spot_price_list...)))
  description = "Raw (without normalization) Maximum spot price within all AZ. This behavior guarantees start the instance in all AZ. This is the maximum price from the list of spot prices."
}

output "spot_price_over_raw" {
  value       = tonumber(format("%f", max(local.spot_price_list...))) * var.custom_max_price_modifier
  description = "Raw (without normalization) The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand."
}

output "spot_price_avg_raw" {
  value       = tonumber(format("%f", sum(local.spot_price_list) / length(local.spot_price_list)))
  description = "Raw (without normalization) Average price within all AZ. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price."
}