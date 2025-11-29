# DNS público del ALB
output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = module.services.alb_dns_name
}

# ID de la VPC creada
output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.network.vpc_id
}

output "db_endpoint" {
  description = "Endpoint del RDS MySQL"
  value       = module.db.db_endpoint
}

output "db_port" {
  description = "Puerto del RDS"
  value       = module.db.db_port
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.computers.asg_name
}
