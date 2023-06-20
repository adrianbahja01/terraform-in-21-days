resource "aws_launch_configuration" "config-main" {
  name_prefix          = "${var.project_name}-"
  instance_type        = var.ec2_type
  image_id             = data.aws_ami.ami_linux.id
  user_data            = file("httpd_install.sh")
  security_groups      = [aws_security_group.private_sg.id]
  iam_instance_profile = aws_iam_instance_profile.iam-profile.name
}

resource "aws_autoscaling_group" "autoscale-main" {
  name                 = "${var.project_name}-autoscale-main"
  launch_configuration = aws_launch_configuration.config-main.name
  max_size             = 3
  min_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = data.terraform_remote_state.tf_remote_state.outputs.private_subnet_id
  target_group_arns    = [aws_lb_target_group.lb-target-main.arn]

  tag {
    key                 = "Name"
    value               = var.project_name
    propagate_at_launch = true
  }
}
