output "lb_dns" {
  value = aws_lb.lb-main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.lb-target-main.arn
}

output "lbsg_id" {
  value = aws_security_group.lb-sg.id
}
