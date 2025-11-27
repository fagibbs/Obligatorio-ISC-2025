# Security Group del ALB
resource "aws_security_group" "sg_alb" {
  name   = "ALB_security_group"
  vpc_id = var.vpc_id

  # Regla de entrada: permitir HTTP desde cualquier origen
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de salida: permite todo tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB que expone el frontend del e-commerce
resource "aws_lb" "alb" {
  # Nombre del ALB
  name               = "alb-ecommerce"
  # Tipo de load balancer: Application
  load_balancer_type = "application"
  # Security Group asociado al ALB
  security_groups    = [aws_security_group.sg_alb.id]
  # Subnets públicas donde se despliega el ALB
  subnets            = var.public_subnets

  # Configuración de logs de acceso del ALB hacia S3
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb-logs"
    enabled = true
  }
}

# Target Group HTTP donde el ALB envía tráfico a las instancias de app
resource "aws_lb_target_group" "tg" {
  name     = "tg-ecommerce"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Configuración de health checks del ALB hacia las instancias de backend
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Escucha HTTP del ALB en el puerto 80
resource "aws_lb_listener" "listener" {
  # ALB sobre el que escucha
  load_balancer_arn = aws_lb.alb.arn
  # Puerto expuesto al cliente
  port              = 80
  protocol          = "HTTP"

  # Redirigir tráfico al Target Group de la app
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Output con el ID del Security Group del ALB (para usar enotros módulos)
output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}

# Output con el ARN del Target Group (para asociarlo desde el ASG)
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

# Output con el DNS público del ALB
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# S3 para logs del ALB y lifecycle

# Bucket S3 donde se almacenarán los logs de acceso del ALB
resource "aws_s3_bucket" "alb_logs" {
  # Nombre del bucket con sufijo aleatorio para evitar colisión
  bucket = "logs-ecommerce-alb-${random_id.suffix.hex}"

  # Permite borrar el bucket aunque tenga objetos
  force_destroy = true
}

# Generar una parte aleatoria en el nombre del bucket
resource "random_id" "suffix" {
  # 4 bytes = 8 caracteres hexadecimales de sufijo
  byte_length = 4
}

# Data con la cuenta de servicio de ELB usada para escribir logs
data "aws_elb_service_account" "main" {}

# Política del bucket que permite al ALB escribir logs en S3
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  # Bucket al que se aplica esa política
  bucket = aws_s3_bucket.alb_logs.id

  # Política en formato JSON: permite PutObject desde la service account de ELB
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# Configuración de ciclo de vida del bucket de logs (Glacier)
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_lifecycle" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    # ID de la regla
    id     = "logs-archive"
    status = "Enabled"

    # Aplicar la regla sólo a objetos con prefijo "alb-logs/"
    filter {
      prefix = "alb-logs/"
    }

    # A los 30 días mover a clase Glacier Instant Retrieval
    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }

    # A los 180 días, pasar a Deep Archive
    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

# CloudWatch Alarms para el ALB

# Alarma que detecta cuando el ALB se queda sin instancias saludables en el Target Group
resource "aws_cloudwatch_metric_alarm" "alb_no_healthy_targets" {
  alarm_name          = "alb-no-healthy-targets"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1

  # Dimensiones: métrica para este Target Group y este Load Balancer
  dimensions = {
    TargetGroup  = aws_lb_target_group.tg.arn_suffix
    LoadBalancer = aws_lb.alb.arn_suffix
  }
  alarm_description = "¡¡¡ALB sin instancias saludables!!!"
}

# Alarma que detecta latencia alta en las respuestas del ALB hacia los clientes
resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "alb-high-latency!!!"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2

  # Dimensiones: mide la latencia del TG y ALB
  dimensions = {
    TargetGroup  = aws_lb_target_group.tg.arn_suffix
    LoadBalancer = aws_lb.alb.arn_suffix
  }
  alarm_description = "Latencia alta en respuestas del ALB..."
}
