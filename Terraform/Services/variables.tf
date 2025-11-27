# ID de la VPC donde se crean el ALB y sus recursos asociados
variable "vpc_id" {
  type = string
}

# Lista de subnets públicas donde se despliega el ALB
variable "public_subnets" {
  type = list(string)
}
