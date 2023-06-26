output "lb_dns" {
  value = module.alb.lb_dns_name
}

output "private_sg_id" {
  value = module.private_sg.security_group_id
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}
