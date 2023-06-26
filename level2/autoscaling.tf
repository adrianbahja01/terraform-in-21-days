module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  create      = true
  name        = "${var.project_name}-private-sg"
  description = "Allow port 80 to EC2 instance on ASG"

  vpc_id = data.terraform_remote_state.tf_remote_state.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.lb_security_gr.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  computed_egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_egress_with_cidr_blocks = 1

  tags = {
    Name = "${var.project_name}-private-sg"
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  depends_on                      = [module.private_sg]
  vpc_zone_identifier             = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  name                            = "${var.project_name}-autoscale-main"
  use_name_prefix                 = true
  min_size                        = 2
  max_size                        = 3
  desired_capacity                = 2
  health_check_type               = "EC2"
  target_group_arns               = module.alb.target_group_arns
  image_id                        = data.aws_ami.ami_linux.id
  instance_type                   = var.ec2_type
  user_data                       = filebase64("httpd_install.sh")
  force_delete                    = true
  create_launch_template          = true
  launch_template_use_name_prefix = true

  # Assume role policy is auto-create here
  create_iam_instance_profile = true
  iam_role_name               = "${var.project_name}-autoscale-main"
  iam_role_path               = "/ec2/"
  iam_role_tags = {
    Name = "${var.project_name}-autoscale-main"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  security_groups = [module.private_sg.security_group_id]

}

resource "aws_iam_policy" "s3-access" {
  depends_on  = [module.asg]
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

resource "aws_iam_policy_attachment" "iam-attach" {
  name       = "${var.project_name}-iam-attach"
  roles      = [module.asg.iam_role_name]
  policy_arn = aws_iam_policy.s3-access.arn
}
