data "aws_availability_zones" "available_azs" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr            = var.vpc_cidr
  name            = var.project_name
  azs             = data.aws_availability_zones.available_azs.names
  public_subnets  = var.public_cidr
  private_subnets = var.private_cidr
  create_vpc      = true

  # One NAT Gateway per subnet (default behavior)
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false


  tags = {
    Name = "${var.project_name}_vpc"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-main" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.project_name}-main" = "shared"
  }
}
