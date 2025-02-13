# VPC 생성
# IGW 생성 및 VPC 연결
# Public Subnet 생성
# Routing Table 생성 및 Public Subnet에 연결

# VPC 생성
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "myVPC"
  }
}

# IGW 생성 및 VPC 연결
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# Public Subnet 생성
resource "aws_subnet" "myPublicSubnet" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  # 퍼블릭 엑세스 가능하도록 설정
  map_public_ip_on_launch = true
  tags = {
    Name = "myPublicSubnet"
  }
}

# Routing Table 생성 및 Public Subnet에 연결
resource "aws_route_table" "myPublicRouteTable" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
    }

  tags = {
    Name = "myPublicRouteTable"
  }
}

resource "aws_route_table_association" "myPublicRouteTableAssociation" {
  subnet_id      = aws_subnet.myPublicSubnet.id
  route_table_id = aws_route_table.myPublicRouteTable.id
}