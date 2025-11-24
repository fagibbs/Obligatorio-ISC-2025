# VPC 
# - Red donde están los recursos
# - CIDR grande para poder dividir en varias subnets

resource "aws_vpc" "main" {
  cidr_block = var.vpc
}

# SUBNETS PRIVADAS PARA BASE DE DATOS
# - No tienen salida a Internet
# - Solo las EC2 acceden a estas subnets

resource "aws_subnet" "db_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_db_az1
  availability_zone = "${var.region}a"
}


resource "aws_subnet" "db_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_db_az2
  availability_zone = "${var.region}b"
}

# NAT GATEWAY
# - Permite que las EC2 salgan a Internet

resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_a.id
}

# ROUTE TABLE PUBLICA
# - Las subnets públicas usan esta tabla
# - El tráfico 0.0.0.0/0 va hacia el IGW luego a Internet

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}


resource "aws_route_table_association" "app_a" {
  subnet_id = aws_subnet.app_a.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "app_b" {
  subnet_id = aws_subnet.app_b.id
  route_table_id = aws_route_table.private.id
}
