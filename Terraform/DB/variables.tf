variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "db_subnets" {
  description = "Subnets privadas para la base de datos"
  type        = list(string)
}

variable "sg_app_id" {
  description = "Security Group de la capa de aplicación"
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}
