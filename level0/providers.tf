terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region  = var.region_name
  profile = var.profile_name
}
