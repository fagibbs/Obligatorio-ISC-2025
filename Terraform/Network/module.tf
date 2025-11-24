resource "aws_vpc" "main" {
resource "aws_subnet" "db_a" {
vpc_id = aws_vpc.main.id
cidr_block = "10.0.20.0/24"
availability_zone = "us-east-1a"
}


resource "aws_subnet" "db_b" {
vpc_id = aws_vpc.main.id
cidr_block = var.private_db_az2
availability_zone = "us-east-1b"
}


resource "aws_eip" "nat" {
}


resource "aws_nat_gateway" "nat" {
allocation_id = aws_eip.nat.id
subnet_id = aws_subnet.public_a.id
}


resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}
}


resource "aws_route_table_association" "public_a" {
subnet_id = aws_subnet.public_a.id
route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public_b" {
subnet_id = aws_subnet.public_b.id
route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
vpc_id = aws_vpc.main.id
route {
cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat.id
}
}


resource "aws_route_table_association" "app_a" {
subnet_id = aws_subnet.app_a.id
route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "app_b" {
subnet_id = aws_subnet.app_b.id
route_table_id = aws_route_table.private.id
}
