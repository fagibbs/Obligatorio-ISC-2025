# Data source que obtiene la AMI más reciente de Amazon Linux 2
# Se usa como referencia global para instancias EC2 si se necesitara desde el root
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  # Filtro por nombre para seleccionar solo Amazon Linux 2 HVM x86_64
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
