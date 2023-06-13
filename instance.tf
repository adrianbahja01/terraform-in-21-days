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

resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}_public"
  description = "This SG will allow SSH+HTTP access only from my Public IP"
  vpc_id      = aws_vpc.vpc_adrian.id

  ingress {
    description = "SSH from my Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sg_allowed_cidrs
  }

  ingress {
    description = "HTTP from my Public IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sg_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_public"
  }

}
resource "aws_instance" "public" {
  ami                         = data.aws_ami.ami_linux.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  instance_type               = var.ec2_type
  key_name                    = var.ssh_key_name
  user_data                   = file("httpd_install.sh")

  tags = {
    Name = "${var.project_name}_public"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}_private"
  description = "This SG will allow SSH access only from my VPC"
  vpc_id      = aws_vpc.vpc_adrian.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_private"
  }

}
resource "aws_instance" "private" {
  ami                    = data.aws_ami.ami_linux.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id              = aws_subnet.private[0].id
  instance_type          = var.ec2_type
  key_name               = var.ssh_key_name

  tags = {
    Name = "${var.project_name}_private"
  }
}

output "ec2_IP" {
  value = aws_instance.public.public_ip
}
