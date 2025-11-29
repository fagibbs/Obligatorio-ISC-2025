# ID de la VPC donde creamos las instancias de aplicación
variable "vpc_id" {
  description = "ID de la VPC donde corre la capa de aplicación"
  type        = string
}

# Lista de subnets privadas donde corre el Auto Scaling Group de app
variable "app_subnets" {
  description = "Subnets privadas donde van las instancias del ASG"
  type        = list(string)
}

# ID del Security Group del ALB (permitido como origen HTTP)
variable "sg_alb_id" {
  description = "Security Group del ALB"
  type        = string
}

# ARN del Target Group del ALB donde el ASG registra las instancias
variable "target_group_arn" {
  description = "ARN del Target Group para el ASG"
  type        = string
}

# Nombre del key pair existente en AWS para acceso SSH
variable "key_name" {
  description = "Nombre del key pair para las instancias EC2"
  type        = string
}

# ID del Security Group de la base de datos (por si se llegara a necesitar filtrar tráfico app hacia DB)
variable "sg_db_id" {
  description = "Security Group del módulo DB"
  type        = string
}

# Tipo de instancia EC2 para las apps
variable "instance_type" {
  description = "Tipo de instancia para el Launch Template"
  type        = string
}

variable "ami_id" {
  description = "AMI para el Launch Template"
  type        = string
}
