resource "aws_security_group" "sg_alb" {
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_lb" "alb" {
name = "alb-ecommerce"
load_balancer_type = "application"
security_groups = [aws_security_group.sg_alb.id]
subnets = var.public_subnets
}


resource "aws_lb_target_group" "tg" {
name = "tg-ecommerce"
port = 80
protocol = "HTTP"
vpc_id = var.vpc_id
}


resource "aws_lb_listener" "listener" {
load_balancer_arn = aws_lb.alb.arn
port = 80
protocol = "HTTP"


default_action {
type = "forward"
target_group_arn = aws_lb_target_group.tg.arn
}
}
