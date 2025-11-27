# Security Group para las instancias de aplicación
resource "aws_security_group" "sg_app" {
  name   = "APP_security_group"
  # VPC donde está el SG
  vpc_id = var.vpc_id

  # Entrada: permite HTTP solo desde el SG del ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.sg_alb_id]
  }

  # Salida: permite todo tráfico saliente (pensando en el acceso a Internet vía NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template para las instancias de aplicación del Auto Scaling Group
resource "aws_launch_template" "app" {
  # Prefijo del launch template
  name_prefix   = "lt-ecommerce-"
  # AMI de Linux obtenida del data source
  image_id      = data.aws_ami.amazon_linux.id
  # Tipo de instancia pasado por variable
  instance_type = var.instance_type
  # Key pair para poder hacer SSH si es necesario
  key_name      = var.key_name

  # Asocia el SG de aplicación a las instancias del launch template
  vpc_security_group_ids = [aws_security_group.sg_app.id]

  # Script de inicialización (user_data) que levanta Apache y genera página simple
  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl stop httpd
systemctl enable httpd
systemctl start httpd
echo "Bien ahí! Funciona el Obligatorio. Hola profe!" > /var/www/html/index.html
chmod 644 /var/www/html/index.html
EOF
)

  # Obliga a usar tokens IMDSv2 para metadatos de instancia
  metadata_options {
    http_tokens = "required"
  }
}

# ASG que mantiene el número de instancias de aplicación
resource "aws_autoscaling_group" "asg" {
  # Subnets privadas donde se lanzan las instancias
  vpc_zone_identifier = var.app_subnets

  # Capacdad deseada y límites de instancias
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6

  # Asociamos el ASG al Target Group del ALB para registrar las instancias como targets
  target_group_arns = [var.target_group_arn]

  # Indica que el ASG usa el launch template definido arriba
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

# Output con el ID del Security Group de aplicación (para poder usarlo en otros módulos)
output "sg_app_id" {
  value = aws_security_group.sg_app.id
}

# Output con el nombre del Auto Scaling Group (para poderlo referenciar)
output "asg_name" {
  value = aws_autoscaling_group.asg.name
}
