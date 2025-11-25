resource "aws_security_group" "sg_db" {
  name   = "sg-db"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg_app_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "ecommerce-db"

  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"     
  allocated_storage = 20
  storage_type = "gp2"
  multi_az = true              
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.sg_db.id]


  tags = {
    Name = "rds-mysql-ecommerce"
  }
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}
