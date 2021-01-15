terraform {
  required_version = ">= 0.13"
  required_providers {
    external = {
      source  = "hashicorp/aws"
      version = ">= 3.13.0"
    }
  }
}