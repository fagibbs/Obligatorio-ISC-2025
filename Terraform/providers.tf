# Configuración global de Terraform
terraform {
 # Versión mínima requerida de Terraform
  required_version = ">= 1.5.0"

 # Proveedores utilizados por el proyecto
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Proveedor AWS con región que usamos siempre
provider "aws" {
  region = var.aws_region
}
