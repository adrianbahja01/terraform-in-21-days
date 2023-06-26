data "aws_route53_zone" "dns-main" {
  name = "cloud-adrian.click"
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  create_certificate = true
  domain_name        = "www.cloud-adrian.click"
  zone_id            = data.aws_route53_zone.dns-main.zone_id

  wait_for_validation = true
}

module "lb_security_gr" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.project_name}-lb-sg"
  description = "This SG will allow HTTP/s access to LB"

  vpc_id = data.terraform_remote_state.tf_remote_state.outputs.vpc_id
  ingress_with_cidr_blocks = [
    {
      description = "HTTPS access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "https to ELB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "${var.project_name}-lb-sg"
  }
}
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  create_lb = true

  name               = "${var.project_name}-lb-main"
  load_balancer_type = "application"

  internal = false
  subnets  = data.terraform_remote_state.tf_remote_state.outputs.public_subnet_id
  vpc_id   = data.terraform_remote_state.tf_remote_state.outputs.vpc_id

  security_groups = [module.lb_security_gr.security_group_id]

  target_groups = [
    {
      name             = "${var.project_name}-target-main"
      backend_port     = 80
      backend_protocol = "HTTP"
      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 15
        matcher             = 200
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  tags = {
    Name = "${var.project_name}-lb-main"
  }
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.dns-main.zone_id
  records = [
    {
      type    = "CNAME"
      name    = "www"
      ttl     = 300
      records = [module.alb.lb_dns_name]
    }
  ]
}
