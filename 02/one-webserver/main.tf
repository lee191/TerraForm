# Provider 설정
provider "aws" {
  region = "us-east-2"
}

# Resource 설정
# 1) SG(80) 그룹 생성
# 2) EC2(user_data="WEB 서버 설정")


# 1) SG(80) 그룹 생성


resource "aws_security_group" "mySG" {
  # 수정 전
  # name        = "allow_80"
  # 수정 후
  name        = var.mywebserver_security_group
  description = "Allow 80 inbound traffic and all outbound traffic"

  tags = {
    Name = "mySG"
  }
}

# [수정후]
resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.server_port
  ip_protocol       = "tcp"
  to_port           = var.server_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 2) EC2(user_data="WEB 서버 설정")
resource "aws_instance" "myweb" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.mySG.id]

  user_data_replace_on_change = true
  user_data = <<EOF
#!/bin/bash
sudo apt -y install apache2
echo 'WEB Server' > /var/www/html/index.html
nohup busybox httpd -f -p 80 &
EOF

  tags = {
    Name = "myweb"
  }
}