variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Ecommerce-Obligatorio-ISC"
  type        = string
  default     = "Ecommerce-Obligatorio-ISC"
}
variable "vpc" { default = "10.0.0.0/16" }
variable "public_subnet" { default = "10.0.1.0/24" } 
variable "private_app_az1" { default = "10.0.10.0/24" }
variable "private_app_az2" { default = "10.0.11.0/24" }
variable "private_db_az1" { default = "10.0.20.0/24" }
variable "private_db_az2" { default = "10.0.21.0/24" }
