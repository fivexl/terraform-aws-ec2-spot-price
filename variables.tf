variable "instance_type" {
  description = "The type of instance"
  type        = string
}

variable "availability_zones_names_list" {
  description = "The list with AZs names"
  type        = list(string)
}

variable "product_description" {
  description = "The product description for the Spot price (Linux/UNIX | Red Hat Enterprise Linux | SUSE Linux | Windows | Linux/UNIX (Amazon VPC) | Red Hat Enterprise Linux (Amazon VPC) | SUSE Linux (Amazon VPC) | Windows (Amazon VPC))."
  type        = string
  default     = "Linux/UNIX"
}

variable "custom_max_price_modifier" {
  description = "Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price."
  type        = number
  default     = 1.05
}