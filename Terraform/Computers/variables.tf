variable "vpc_id" {
  description = "ID de la VPC donde corre la capa de aplicación"
  type        = string
}

variable "app_subnets" {
  description = "Subnets privadas donde van las instancias del ASG"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "Security Group del ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN del Target Group para el ASG"
  type        = string
}

variable "key_name" {
  description = "Nombre del key pair para las instancias EC2"
  type        = string
}
variable "sg_db_id" {
  description = "Security Group del módulo DB"
  type        = string
}
variable "instance_type" {
  description = "Tipo de instancia para el Launch Template"
  type        = string
}
variable "ami_id" {
  description = "AMI para el Launch Template"
  type        = string
}
