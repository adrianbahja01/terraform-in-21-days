module "vpc" {
  source = "../modules/vpc"

  vpc_cidr                = var.vpc_cidr
  project_name            = var.project_name
  availability_zone_names = var.availability_zone_names
  public_cidr             = var.public_cidr
  private_cidr            = var.private_cidr
}
