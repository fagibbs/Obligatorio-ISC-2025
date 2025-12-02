# Security Group para las instancias de aplicación
resource "aws_security_group" "sg_app" {
  name   = "app-sg"
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
  image_id = var.ami_id
 # Tipo de instancia pasado por variabl
  instance_type = var.instance_type
 # Key pair para poder hacer SSH si es necesario
  key_name      = var.key_name

# Asocia el SG de aplicación a las instancias del launch template
  vpc_security_group_ids = [aws_security_group.sg_app.id]

# Script de inicialización (user_data) que levanta Apache y genera página simple
  user_data = base64encode(<<EOF
#!/bin/bash
 
# Actualizo paquetes
yum update -y
 
# Instalo apache
yum install -y httpd
 
# Habilito y arranco el servicio
systemctl enable httpd
systemctl start httpd
 
# Creo la página para probar desde el ALB
echo "EC2 APP FUNCIONÓ PROFE!!!" > /var/www/html/index.html
chmod 644 /var/www/html/index.html
 
# Espero a que Apache realmente esté escuchando en el puerto 80
for i in {1..10}; do
    systemctl is-active --quiet httpd && break
    sleep 3
done
 
# Fuerzo reinicio si por alguna razón no levantó
systemctl restart httpd
EOF
  )

# Obliga a usar tokens IMDSv2 para metadatos de instancia
  metadata_options {
    http_tokens = "required"
  }
}

# ASG que mantiene el número de instancias de aplicación
resource "aws_autoscaling_group" "asg" {
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
  version = aws_launch_template.app.latest_version
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
