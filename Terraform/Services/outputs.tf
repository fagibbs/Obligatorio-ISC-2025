output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
