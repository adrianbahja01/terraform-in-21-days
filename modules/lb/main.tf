resource "aws_security_group" "lb-sg" {
  name        = "${var.project_name}-lb-sg"
  description = "This SG will allow HTTP access to LB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lb-sg"
  }

}
resource "aws_lb" "lb-main" {
  name               = "${var.project_name}-lb-main"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = var.public_subnet_id

  tags = {
    Name = "${var.project_name}-lb-main"
  }
}

resource "aws_lb_target_group" "lb-target-main" {
  name     = "${var.project_name}-target-main"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
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

resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.lb-main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.lb-acm.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-main.arn
  }
}

resource "aws_lb_listener" "http-listener" {
    depends_on = [ aws_lb_listener.https-listener ]
    load_balancer_arn = aws_lb.lb-main.arn
    port = 80
    protocol = "HTTP"

    default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
