variable "instance_type" {
  description = "The type of instance"
  type        = string
}

variable "availability_zones_names_list" {
  description = "The list with AZs names"
  type        = list(string)
}

variable "product_description_list" {
  description = "The product description for the Spot price (Linux/UNIX | Red Hat Enterprise Linux | SUSE Linux | Windows | Linux/UNIX (Amazon VPC) | Red Hat Enterprise Linux (Amazon VPC) | SUSE Linux (Amazon VPC) | Windows (Amazon VPC))."
  type        = list(string)
  default     = ["Linux/UNIX", "Linux/UNIX (Amazon VPC)"]
}

variable "custom_max_price_modifier" {
  description = "Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price."
  type        = number
  default     = 1.05
  validation {
    condition     = var.custom_max_price_modifier >= 1 && var.custom_max_price_modifier <= 2
    error_message = "Modifier for getting custom prices. Must be between 1 and 2. Values greater than 1.7 will often not make sense. Because it will be equal or greater than on-demand price."
  }
}

variable "normalization_modifier" {
  description = "Modifier for price normalization (rounded up / ceil). Helps to avoid small price fluctuations. Must be 10, 100, 1000 or 10000."
  type        = number
  default     = 1000
  validation {
    condition     = contains([10, 100, 1000, 10000], var.normalization_modifier)
    error_message = "Modifier for price normalization must be 10, 100, 1000 or 10000."
  }
}