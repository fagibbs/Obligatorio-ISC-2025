# ID de la VPC donde creamos las instancias de aplicación
variable "vpc_id" {
  type = string
}

# Lista de subnets privadas donde corre el Auto Scaling Group de app
variable "app_subnets" {
  type = list(string)
}

# ID del Security Group del ALB (permitido como origen HTTP)
variable "sg_alb_id" {
  type = string
}

# ID del Security Group de la base de datos (por si se llegara a necesitar filtrar tráfico app hacia DB)
variable "sg_db_id" {
  type = string
}

# ARN del Target Group del ALB donde el ASG registra las instancias
variable "target_group_arn" {
  type = string
}

# Tipo de instancia EC2 para las apps
variable "instance_type" {
  type = string
}

# Nombre del key pair existente en AWS para acceso SSH
variable "key_name" {
  type = string
}
