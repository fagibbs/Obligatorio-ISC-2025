# Security Group de la "base de datos" (La EC2 que simula el RDS)
resource "aws_security_group" "sg_db" {
  name   = "DB_security_group"
  # VPC donde está el SG de base de datos
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia EC2 que simula la base de datos (en lugar de un RDS por restricciones de permisos de usuario)
resource "aws_instance" "db" {
  # AMI de Amazon Linux tomada del data source
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  # Se coloca en la primera subnet de la lista de subnets de base de datos (privada)
  subnet_id     = var.db_subnets[0]
  # Key pair para poder acceder por SSH si se necesita administrar la BD
  key_name      = var.key_name

  # No le asignamos IP pública: queda estrictamente en red privada
  associate_public_ip_address = false

  # Se asocia al Security Group de DB
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  # Inicialización: instalar y arrancar MySQL Server
  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y mysql-server
systemctl enable mysqld
systemctl start mysqld
EOF
  )

  # Tag de la instancia en la consola
  tags = {
    Name = "ec2-db-ecommerce"
  }
}

# Output con la IP privada de la instancia de DB
output "db_private_ip" {
  value = aws_instance.db.private_ip
}

# Output con el ID del Security Group de DB (para referenciar desde otros módulos si se necesita)
output "sg_db_id" {
  value = aws_security_group.sg_db.id
}
