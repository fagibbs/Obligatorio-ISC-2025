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

resource "aws_instance" "db" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = var.db_subnets[0]
  key_name      = var.key_name

  associate_public_ip_address = false

  vpc_security_group_ids = [aws_security_group.sg_db.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y mysql-server
systemctl enable mysqld
systemctl start mysqld
EOF
  )

  tags = {
    Name = "ec2-db-ecommerce"
  }
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}
