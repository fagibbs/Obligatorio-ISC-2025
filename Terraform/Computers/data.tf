# Data source para obtener la AMI más reciente de Amazon Linux 2 (x86_64, gp2)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  # Filtra solo AMIs que coincidan con el patrón de Amazon Linux 2 HVM
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
