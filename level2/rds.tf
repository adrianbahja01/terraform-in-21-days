locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_pass"]
}

module "rds" {
  source = "../modules/rds"

  vpc_id            = data.terraform_remote_state.tf_remote_state.outputs.vpc_id
  subnet_ids        = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  allowed_source_sg = module.ec2.private_sg_id
  engine_type       = "mysql"
  engine_ver        = "5.7"
  db_instance_type  = "db.t3.micro"
  db_password       = local.db_password
  project_name      = var.project_name

}
