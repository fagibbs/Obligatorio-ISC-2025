# ID de la VPC donde se crea la instancia de base de datos
variable "vpc_id" {
  type = string
}

# Lista de subnets privadas destinadas a la capa de base de datos
variable "db_subnets" {
  type = list(string)
}

# ID del Security Group de las aplicaciones (origen permitido hacia la DB)
variable "sg_app_id" {
  type = string
}

# Nombre del key pair usado para acceder por SSH a la instancia de DB
variable "key_name" {
  type = string
}
