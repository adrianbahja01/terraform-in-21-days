terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.4.0"
  backend "s3" {
    bucket = "tf-remote-state-ab/"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-dynamodb"
    profile = "adrianpersonal"
  }
}

provider "aws" {
  region  = var.region_name
  profile = var.profile_name
}
