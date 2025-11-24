resource "aws_instance" "db" {
ami = data.aws_ami.amazon_linux.id
instance_type = "t3.micro"
subnet_id = var.db_subnets[0]
key_name = var.key_name


associate_public_ip_address = false


vpc_security_group_ids = [aws_security_group.sg_db.id]


user_data = base64encode("#!/bin/bash\nyum install -y mysql-server\nsystemctl start mysqld\nsystemctl enable mysqld")
}


resource "aws_security_group" "sg_db" {
name = "sg-db"
vpc_id = var.vpc_id


ingress {
from_port = 3306
to_port = 3306
protocol = "tcp"
security_groups = [var.sg_app_id]
}
}
