[![FivexL](https://releases.fivexl.io/fivexlbannergit.jpg)](https://fivexl.io/)

# AWS EC2 Spot Price Terraform module
An easy way to get the best Spot Instance price.

```hlc
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

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  instance_type = "t3a.xlarge"
}

module "ec2_spot_price" {
  source                        = "fivexl/ec2-spot-price/aws"
  version                       = "1.0.3"
  instance_type                 = local.instance_type
  availability_zones_names_list = data.aws_availability_zones.available.names
}

resource "aws_spot_instance_request" "spot" {
  ami           = data.aws_ami.ubuntu.id
  spot_price    = module.ec2_spot_price.spot_price_max
  instance_type = local.instance_type
}
```

## Amazon EC2 Pricing
- [On-Demand](https://aws.amazon.com/ec2/pricing/on-demand/)
- [Spot Instances](https://aws.amazon.com/ec2/spot/pricing/)
- [Savings Plans](https://aws.amazon.com/savingsplans/)
- [Reserved Instances](https://aws.amazon.com/ec2/pricing/reserved-instances/)
- [Dedicated Hosts](https://aws.amazon.com/ec2/dedicated-hosts/pricing/)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.13.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_type | The type of instance | `string` |  | yes |
| availability_zones_names_list | The list with AZs names | `list(string)` |  | yes |
| product_description_list | The product description list for the Spot price (Linux/UNIX, Red Hat Enterprise Linux , SUSE Linux , Windows , Linux/UNIX (Amazon VPC) , Red Hat Enterprise Linux (Amazon VPC) , SUSE Linux (Amazon VPC) , Windows (Amazon VPC)). | `list(string)` | `"Linux/UNIX"` | no |
| custom_max_price_modifier | Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price. | `number` | `1.05` | no |
| normalization_modifier | Modifier for price normalization (rounded up / ceil). Helps to avoid small price fluctuations. Must be 10, 100, 1000 or 10000. | `number` | `1000` | no |

## Outputs

| Name | Description |
|------|-------------|
| spot_price_min | Minimum spot price within all AZ. This behavior does not guarantee the launch of the instance in all AZ. Can be used as a way to get the lowest possible price. |
| spot_price_max | Recommended use. Maximum spot price within all AZ. This behavior guarantees start the instance in all AZ. This is the maximum price from the list of spot prices. |
| spot_price_over | The maximum spot price within all AZs multiplied by the `custom_max_price_modifier`. Instance at this price can be launched in any in all AZ. This behavior can add stability in the event of price increases and frequent demand. |
| spot_price_avg | Average price within all AZ. This behavior guarantees the launch of an instance in at least one AZ, but does not guarantee launch in all AZ. Can be used as a balance between stability and price. |
| spot_price_min_raw | Raw (without normalization) Minimum spot price |
| spot_price_max_raw | Raw (without normalization) Maximum spot price |
| spot_price_over_raw | Raw (without normalization) The maximum spot price within all AZs multiplied by the `custom_max_price_modifier` |
| spot_price_avg_raw | Raw (without normalization) Average price |


## License

Apache 2 Licensed. See LICENSE for full details.
