[![FivexL](https://releases.fivexl.io/fivexlbannergit.jpg)](https://fivexl.io/)

# AWS EC2 Spot Price Terraform module
An easy way to get the best Spot price to control costs.

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
  instance_types_list = ["t3a.xlarge"]
}

module "ec2_spot_price" {
  source                        = "fivexl/ec2-spot-price/aws"
  version                       = "2.0.0"
  instance_types_list           = local.instance_types_list
  availability_zones_names_list = data.aws_availability_zones.available.names
}

resource "aws_spot_instance_request" "spot" {
  ami           = data.aws_ami.ubuntu.id
  spot_price    = module.ec2_spot_price.spot_price_current_max
  instance_type = local.instance_type
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.13.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_types_list | List of instance types. If not default will overwrite `instance_types_weighted_map`. | `list(string)` | `[]` | no |
| instance_types_weighted_map | Map of instance_type and their weighted_capacity. Conflict with `instance_types_list` | `list(object({ instance_type = string, weighted_capacity = string}))` | `[{ instance_type = "t3.micro", weighted_capacity = "1" }]` | no |
| instance_weight_default | Default number of capacity units for all instance types. | `number` | `1` | no |
| availability_zones_names_list | The list with AZs names | `list(string)` |  | yes |
| product_description_list | The product description list for the Spot price (Linux/UNIX, Red Hat Enterprise Linux , SUSE Linux , Windows , Linux/UNIX (Amazon VPC) , Red Hat Enterprise Linux (Amazon VPC) , SUSE Linux (Amazon VPC) , Windows (Amazon VPC)). | `list(string)` | `"Linux/UNIX"` | no |
| custom_price_modifier | Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price. | `number` | `1.05` | no |
| normalization_modifier | Modifier for price normalization (rounded up / ceil). Helps to avoid small price fluctuations. Must be 10, 100, 1000 or 10000. | `number` | `1000` | no |

## Outputs

| Name | Description |
|------|-------------|
| spot_price_current_max | Maximum current Spot Price, which allows to run all Instance Types in all AZ. Maximum stability. |
| spot_price_current_max_mod | Modified maximum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply. |
| spot_price_current_min | Minimum current Spot Price, which allows to run at least one Instance Type in at least one AZ. Lowest price. |
| spot_price_current_min_mod | Modified minimum current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply. |
| spot_price_current_optimal | Optimal current Spot Price, which allows to run at least one Instance Type in all AZ. Balance between stability and costs. |
| spot_price_current_optimal_mod | Modified optimal current Spot Price. (multiplied by the `custom_price_modifier`). Additional stability on rare runs of terraform apply. |

## License

Apache 2 Licensed. See LICENSE for full details.

# Notes

## Amazon EC2 Pricing
- [On-Demand](https://aws.amazon.com/ec2/pricing/on-demand/)
- [Spot Instances](https://aws.amazon.com/ec2/spot/pricing/)
- [Savings Plans](https://aws.amazon.com/savingsplans/)
- [Reserved Instances](https://aws.amazon.com/ec2/pricing/reserved-instances/)
- [Dedicated Hosts](https://aws.amazon.com/ec2/dedicated-hosts/pricing/)

## AWS EC2 Auto Scaling
- [Instance weighting](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-weighting.html)

## How to determine how much Spot Instance costs - Spot Instance data feed
[Spot Instance data feed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html)
```hcl
data "aws_canonical_user_id" "current" {}

module "s3_spot_datafeed" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.17.0"

  bucket = "spot-data-feed-example"
  acl    = null
  grant = [{
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = data.aws_canonical_user_id.current.id
    }, {
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  // S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# There is only a single subscription allowed per account.
resource "aws_spot_datafeed_subscription" "default" {
  bucket = module.s3_spot_datafeed.this_s3_bucket_id
  prefix = "spot-data-feed" #required
}
```
