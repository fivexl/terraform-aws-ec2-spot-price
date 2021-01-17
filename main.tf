data "aws_ec2_spot_price" "this" {
  count         = length(var.availability_zones_names_list)
  instance_type = var.instance_type
  filter {
    name   = "product-description"
    values = var.product_description_list
  }
  filter {
    name   = "availability-zone"
    values = [element(var.availability_zones_names_list, count.index)]
  }
}
