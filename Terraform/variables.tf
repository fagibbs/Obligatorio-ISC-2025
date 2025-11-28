variable "aws_region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}
variable "region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "Ecommerce-Obligatorio-ISC"
}

variable "vpc_cidr" {
  description = "CIDR principal de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a" {
  description = "Subnet pública AZ us-east-1a"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_b" {
  description = "Subnet pública AZ us-east-1b"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_app_az1" {
  description = "Subnet privada App AZ1"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_app_az2" {
  description = "Subnet privada App AZ2"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_db_az1" {
  description = "Subnet privada DB AZ1"
  type        = string
  default     = "10.0.20.0/24"
}

variable "private_db_az2" {
  description = "Subnet privada DB AZ2"
  type        = string
  default     = "10.0.21.0/24"
}

variable "instance_type" {
  description = "Tipo de instancia para servidores APP"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Nombre del key pair existente en AWS"
  type        = string
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "admin111"
}
