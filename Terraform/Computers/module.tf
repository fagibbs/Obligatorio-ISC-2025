resource "aws_security_group" "sg_app" {
  name   = "sg-app"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.sg_alb_id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg_db_id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "lt-ecommerce-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.sg_app.id]

  user_data = base64encode("#!/bin/bash
yum install -y httpd
systemctl start httpd
echo 'EC2 APP OK' > /var/www/html/index.html")

  metadata_options {
    http_tokens = "required"
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.app_subnets
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

output "sg_app_id" {
  value = aws_security_group.sg_app.id
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

