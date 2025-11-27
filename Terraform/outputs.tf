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

# IP privada de la instancia que simula la base de datos
output "db_private_ip" {
  description = "IP privada de la base de datos (EC2 simulando RDS)"
  value       = module.db.db_private_ip
}

# Nombre del ASG de la capa de aplicación
output "asg_name" {
  description = "Nombre del Auto Scaling Group de la capa APP"
  value       = module.computers.asg_name
}

# Nombre del bucket donde se almacenan los logs del ALB
output "alb_logs_bucket" {
  value = module.services.alb_logs_bucket
}
