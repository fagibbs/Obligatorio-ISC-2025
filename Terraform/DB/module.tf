# Security Group de la "base de datos" (La EC2 que simula el RDS)
resource "aws_security_group" "sg_db" {
  name   = "db-sg"
  vpc_id = var.vpc_id

# Regla de entrada: permiitir MySQL (3306) solo desde las instancias de aplicación
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg_app_id]
  }

# Regla de salida: permite todo tráfico saliente (para actualizar paquetes y demás)
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnets
}

# Instancia DB
resource "aws_db_instance" "mysql" {
  identifier           = "ecommerce-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  multi_az             = true

  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.sg_db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
}

