data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs_max  = 3
  azs_list = slice(data.aws_availability_zones.available.names, 0, tonumber(local.azs_max))
}

# The order of types affects their priority in ASG
locals {
  instance_types_weighted = [
    { instance_type = "c5.2xlarge", weighted_capacity = "2" },
    { instance_type = "c5.4xlarge", weighted_capacity = "4" },
    { instance_type = "c5.12xlarge", weighted_capacity = "12" },
    { instance_type = "c5a.2xlarge", weighted_capacity = "2" },
    { instance_type = "c5a.4xlarge", weighted_capacity = "4" },
    { instance_type = "c5a.12xlarge", weighted_capacity = "12" }
  ]
}

module "spot-price" {
  source                        = "../../"
  availability_zones_names_list = local.azs_list
  instance_types_weighted_map   = local.instance_types_weighted
  product_description_list      = ["Linux/UNIX", "Linux/UNIX (Amazon VPC)"]
  custom_price_modifier         = 1.03
  normalization_modifier        = 1000
}

resource "aws_launch_template" "this" {
  description            = "spot price demo"
  update_default_version = true
  image_id               = data.aws_ami.ubuntu.image_id
  instance_type          = local.instance_types_weighted[0].instance_type
}

resource "aws_autoscaling_group" "this" {
  desired_capacity    = 36
  max_size            = 48
  min_size            = 12
  vpc_zone_identifier = module.vpc.public_subnets
  capacity_rebalance  = true
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = aws_launch_template.this.latest_version
      }
      dynamic "override" {
        for_each = local.instance_types_weighted
        content {
          instance_type     = override.value.instance_type
          weighted_capacity = override.value.weighted_capacity
        }
      }
    }
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      #spot_max_price                           = module.spot-price.spot_price_current_max
      spot_max_price = module.spot-price.spot_price_current_optimal
      #spot_max_price                           = module.spot-price.spot_price_current_min
    }
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 1 #demo only, 120
      min_healthy_percentage = 0 #demo only, 90
    }
  }
  health_check_grace_period = 1
  enabled_metrics = [
    "GroupDesiredCapacity", "GroupInServiceCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupTotalCapacity", "GroupTotalInstances"
  ]
}
