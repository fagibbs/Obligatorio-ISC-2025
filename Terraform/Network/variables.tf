# CIDR de la VPC principal
variable "vpc_cidr" {
  type = string
}

# CIDR de la subnet pública en us-east-1a
variable "public_subnet_a" {
  type = string
}

# CIDR de la subnet pública en us-east-1b
variable "public_subnet_b" {
  type = string
}

# CIDR de la subnet privada de aplicaciones en AZ1
variable "private_app_az1" {
  type = string
}

# CIDR de la subnet privada de aplicaciones en AZ2
variable "private_app_az2" {
  type = string
}

# CIDR de la subnet privada de base de datos en AZ1
variable "private_db_az1" {
  type = string
}

# CIDR de la subnet privada de base de datos en AZ2
variable "private_db_az2" {
  type = string
}

# Región usada (no la usamos dentro del módulo pero está disponible si se necesita)
variable "region" {
  type = string
}
