# ==================
# Provider 설정
# ==================
provider "aws" {
  region = "us-east-2"
}

# =========================================
# 작업 :VPC + Subnet
# 작업 절차 :
# * VPC 생성
# * Internet Gateway 생성
# * VPC에 Public Subnet 생성
# * Routing Table 생성
# * Public Subnet에 연결
# =========================================

# ==================
# Resource 설정
# ==================

# 1. VPC 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# 2. Internet Gateway 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# 3. Public Subnet 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# map_public_ip_on_launch
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

# 4. Routing Table 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}
# 5. Public Subnet에 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "myPubRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

# =========================================
# 작업 : 웹서버 EC2 생성(Amazon Linux 2023 AMI 사용)하고 테스트
# 작업 절차: 
# * Security Group 생성
# * EC2 생성(user_data)
# * 웹 테스트
# =========================================


# 1. Security Group 생성
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 2. EC2 생성(user_data)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "myWEB" {
    # Amazon Linux 2023 AMI
    ami                     = "ami-018875e7376831abe"
    instance_type           = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mySG.id]
    user_data_replace_on_change = true
    subnet_id   = aws_subnet.myPubSN.id

    user_data =<<-EOF
        #!/bin/bash
        dnf -y install httpd mod_ssl
        echo "MYWEB" > /var/www/html/index.html
        systemctl enable --now httpd
        EOF
        
    tags = {
        Name = "myWEB"
    }
}