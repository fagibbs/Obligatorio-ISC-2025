# Output con el nombre del bucket donde se guardan los logs del ALB
output "alb_logs_bucket" {
  value = aws_s3_bucket.alb_logs.bucket
}
