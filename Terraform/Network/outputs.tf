output "vpc_id" { value = aws_vpc.main.id }
output "public_subnets" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "app_subnets" { value = [aws_subnet.app_a.id, aws_subnet.app_b.id] }
output "db_subnets" { value = [aws_subnet.db_a.id, aws_subnet.db_b.id] }
