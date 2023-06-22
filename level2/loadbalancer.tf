module "lb" {
  source = "../modules/lb"

  public_subnet_id = data.terraform_remote_state.tf_remote_state.outputs.public_subnet_id
  project_name     = var.project_name
  vpc_id           = data.terraform_remote_state.tf_remote_state.outputs.vpc_id
}
