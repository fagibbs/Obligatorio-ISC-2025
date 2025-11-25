output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = module.services.alb_dns_name
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.network.vpc_id
}

output "db_private_ip" {
  description = "IP privada de la base de datos (EC2 simulando RDS)"
  value       = module.db.db_private_ip
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group de la capa APP"
  value       = module.computers.asg_name
}
