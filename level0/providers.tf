terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region  = var.region_name
  profile = var.profile_name
}