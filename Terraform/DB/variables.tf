# ID de la VPC donde se crea la instancia de base de datos
variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

# Lista de subnets privadas destinadas a la capa de base de datos
variable "db_subnets" {
  description = "Subnets privadas para la base de datos"
  type        = list(string)
}

# ID del Security Group de las aplicaciones (origen permitido hacia la DB)
variable "sg_app_id" {
  description = "Security Group de la capa de aplicación"
  type        = string
}

# Nombre del usuario de la base de datos
variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
}

# Idem pero la contraseña
variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}
