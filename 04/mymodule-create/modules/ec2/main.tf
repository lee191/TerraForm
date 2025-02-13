# Security Group 생성
# Keypair 생성
# 새로 생성한 VPC/Public Subnet에 EC2 인스턴스 생성


# Security Group 생성
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "SSH_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "HTTP_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Keypair 생성
resource "aws_key_pair" "myKeyPair" {
  key_name   = "myKeyPair"
  public_key = file("~/.ssh/lsjkey.pub")
}

# 새로 생성한 VPC/Public Subnet에 EC2 인스턴스 생성
resource "aws_instance" "myEC2" {
  ami           = "ami-037f2fa59e7cfbbbb"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.myKeyPair.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data = filebase64("${path.module}/userdata.sh")

  tags = {
    Name = "myEC2"
  }
}