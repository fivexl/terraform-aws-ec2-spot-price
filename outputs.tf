output "spot_price_min" {
  value = tonumber(format("%.4f", min([for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)]...)))
  description = "Minimum spot price within all AZ. This behavior does not guarantee the launch of the instance in all AZ. Can be used as a way to get the lowest possible price."
}

output "spot_price_max" {
  value = tonumber(format("%.4f", max([for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)]...)))
  description = "Recommended use. Maximum spot price within all AZ. This behavior guarantees start the instance in all AZ. This is the maximum price from the list of spot prices."
}

output "spot_price_over" {
  value = tonumber(format("%.4f", (max([for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)]...) * var.custom_max_price_modifier)))
  description = "The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand."
}

output "spot_price_avg" {
  value = tonumber(format("%.4f", sum([for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)]) / length([for price in data.aws_ec2_spot_price.this[*].spot_price : tonumber(price)])))
  description = "Average price within all AZ. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price."
}
