module "ec2" {
  source = "../modules/ec2"

  vpc_id            = data.terraform_remote_state.tf_remote_state.outputs.vpc_id
  project_name      = var.project_name
  ec2_type          = var.ec2_type
  ami_id            = data.aws_ami.ami_linux.id
  private_subnet_id = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  target_group_arn  = module.lb.target_group_arn
  lbsg_id           = module.lb.lbsg_id
}
