output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Subnets públicas (ALB y NAT)"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "app_subnets" {
  description = "Subnets privadas para servidores de aplicación"
  value       = [aws_subnet.app_a.id, aws_subnet.app_b.id]
}

output "db_subnets" {
  description = "Subnets privadas para base de datos"
  value       = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}
