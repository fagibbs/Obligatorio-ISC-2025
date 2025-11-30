# Security Group del ALB
resource "aws_security_group" "sg_alb" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  # ALB acepta tráfico HTTP desde internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress por defecto (no necesita reglas adicionales)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${lower(var.project_name)}-alb-logs"

  tags = {
    Name = "${lower(var.project_name)}-alb-logs"
  }
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

resource "aws_lb" "alb" {
  name               = "alb-ecommerce"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }

  tags = {
    Name = "alb-ecommerce"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "tg-ecommerce"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

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
