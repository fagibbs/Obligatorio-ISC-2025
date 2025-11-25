output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = module.services.alb_dns_name
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.network.vpc_id
}

output "db_endpoint" {
  description = "Endpoint de la base de datos MySQL"
  value       = aws_db_instance.mysql.endpoint
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group de la capa APP"
  value       = module.computers.asg_name
}
