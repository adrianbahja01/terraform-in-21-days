data "terraform_remote_state" "tf_remote_state" {
  backend = "s3"

  config = {
    bucket  = "tf-remote-state-ab"
    key     = "level1.tfstate"
    region  = "us-east-1"
    profile = "adrianpersonal"
  }
}

data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_secretsmanager_secret" "db_secret" {
  name = "db_secret"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}
