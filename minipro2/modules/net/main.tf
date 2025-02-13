// modules/net/main.tf
// VPC, Internet Gateway, Subnet, Route Table 등을 생성합니다.

# VPC 생성
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MiniProject-VPC"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "MiniProject-IGW"
  }
}

# Public 서브넷 생성 (각 가용 영역에 하나씩)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "MiniProject-Public-${var.availability_zones[count.index]}"
  }
}

# Private 서브넷 생성 (각 가용 영역에 하나씩)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "MiniProject-Private-${var.availability_zones[count.index]}"
  }
}

# Public 라우트 테이블 생성 (인터넷 접근을 위한 IGW 연결)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "MiniProject-Public-RT"
  }
}

# Public 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
