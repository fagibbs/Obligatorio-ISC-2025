# VPC principal donde vive toda la arquitectura del e-commerce
resource "aws_vpc" "main" {
  # Rango de direcciones IP de la VPC
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-ecommerce"
  }
}

# Internet Gateway para permitir salida/entrada desde Internet a la VPC
resource "aws_internet_gateway" "igw" {
  # Asociamos la VPC principal
  vpc_id = aws_vpc.main.id
}

# SUBNETS PÚBLICAS (ALB, NAT)

# Subnet pública en us-east-1a (para ALB y NAT)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a
  availability_zone       = "us-east-1a"
  # Asignar IP pública automáticamente a las instancias que se inicien aquí
  map_public_ip_on_launch = true
}

# Subnet pública en us-east-1b (pensando en alta disponibilidad para ALB)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# SUBNETS PRIVADAS (APP)

# Subnet privada de aplicaciones en AZ us-east-1a
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_az1
  availability_zone = "us-east-1a"
}

# Subnet privada de aplicaciones en AZ us-east-1b
resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_az2
  availability_zone = "us-east-1b"
}

# SUBNETS PRIVADAS (DB)

# Subnet privada para base de datos en us-east-1a
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_az1
  availability_zone = "us-east-1a"
}

# Subnet privada para base de datos en us-east-1b
resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_az2
  availability_zone = "us-east-1b"
}

# NAT Gateway para salida a Internet desde subnets privadas

# Elastic IP que usará el NAT Gateway
resource "aws_eip" "nat" {
# (Sin parámetros extra)
}

# NAT Gateway ubicado en la subnet pública A
resource "aws_nat_gateway" "nat" {
  # Usa el EIP anterior como dirección pública del NAT
  allocation_id = aws_eip.nat.id
  # Debe estar en una subnet pública para poder salir a Internet
  subnet_id     = aws_subnet.public_a.id
}

# TABLA DE RUTEO PÚBLICA

# Route Table para subnets públicas (ALB y NAT)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Ruta por defecto de Internet (0.0.0.0/0) hacia el Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Asocia la subnet pública A a la tabla de ruteo pública
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Asocia la subnet pública B a la TR pública
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# TABLA DE RUTEO PRIVADA (APP)

# Route Table para las subnets privadas de app
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Ruta por defecto de salida a Internet a través del NAT
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Asocia subnet privada de app en AZ1 a la tabla privada
resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.private.id
}

# Asocia subnet privada de app en AZ2 a la tabla privada
resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.private.id
}
