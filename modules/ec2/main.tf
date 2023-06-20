resource "aws_iam_policy" "s3-access" {
  name        = "${var.project_name}-s3-access"
  description = "This is the policy for s3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      },
    ]
  })
}

resource "aws_iam_role" "main-role" {
  name                = "${var.project_name}-main-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-main-role"
  }
}

resource "aws_iam_policy_attachment" "iam-attach" {
  name       = "${var.project_name}-iam-attach"
  roles      = [aws_iam_role.main-role.name]
  policy_arn = aws_iam_policy.s3-access.arn
}

resource "aws_iam_instance_profile" "iam-profile" {
  name = "${var.project_name}-iam-profile"
  role = aws_iam_role.main-role.name
}

resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}_public"
  description = "This SG will allow SSH access only from my Public IP"
  vpc_id      = var.vpc_id

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

resource "aws_security_group" "private_sg" {
  name        = "${var.project_name}_private"
  description = "This SG will allow SSH from my VPC and HTTP access from LB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lbsg_id]
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

resource "aws_launch_configuration" "config-main" {
  name_prefix          = "${var.project_name}-"
  instance_type        = var.ec2_type
  image_id             = var.ami_id
  user_data            = file("${path.module}/httpd_install.sh")
  security_groups      = [aws_security_group.private_sg.id]
  iam_instance_profile = aws_iam_instance_profile.iam-profile.name
}

resource "aws_autoscaling_group" "autoscale-main" {
  name                 = "${var.project_name}-autoscale-main"
  launch_configuration = aws_launch_configuration.config-main.name
  max_size             = 3
  min_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = var.private_subnet_id
  target_group_arns    = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = var.project_name
    propagate_at_launch = true
  }
}
