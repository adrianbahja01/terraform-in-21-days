data "aws_secretsmanager_secret" "db_secret" {
  name = "db_secret"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["db_pass"]
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  create      = true
  name        = "${var.project_name}-rds-sg"
  description = "Allow port 3306 from ASG"

  vpc_id = data.terraform_remote_state.tf_remote_state.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.private_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  subnet_ids                  = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  vpc_security_group_ids      = [module.rds_sg.security_group_id]
  identifier                  = var.project_name
  engine                      = "mysql"
  engine_version              = "5.7"
  db_name                     = "mydb"
  instance_class              = "db.t3.micro"
  password                    = local.db_password
  username                    = "admin"
  multi_az                    = false
  manage_master_user_password = false
  allocated_storage           = 5
  port                        = "3306"
  create_db_subnet_group      = true
  family                      = "mysql5.7"
  major_engine_version        = "5.7"

}
