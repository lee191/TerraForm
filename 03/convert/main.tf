# ========================= #
# 1. VPC 셍성
# 2. IGW 셍성
# 4. 서브넷 생성
# 5. RT 생성
# 6. SG 생성
# 7. EC2 생성
# 8. ALB - TG(ASG,EC2x2) 
#   * ALB - TG
#       - SG 셍성
#       - TG 생성
#       - ALB 생성
#       - ALB listener 생성
#       - ALB listener rule 생성
# ========================= #



provider "aws" {
  region = "us-east-2"
}

# Resource: aws_vpc
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myVPC"
  }
}

# Resource: aws_internet_gateway
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# Resource: aws_subnet
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "My-Public-SN-1" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "My-Public-SN-1"
  }
}
resource "aws_subnet" "My-Public-SN-2" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "My-Public-SN-2"
  }
}

# Resource: aws_route_table
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "My-Public-RT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "My-Public-RT"
  }
}
resource "aws_route_table_association" "myPubRTassoc1" {
  subnet_id      = aws_subnet.My-Public-SN-1.id
  route_table_id = aws_route_table.My-Public-RT.id
}
resource "aws_route_table_association" "myPubRTassoc2" {
  subnet_id      = aws_subnet.My-Public-SN-2.id
  route_table_id = aws_route_table.My-Public-RT.id
}

# Resource: aws_security_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow 80,22 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_22_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Resource: aws_instance
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.image]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "myWeb1" {
  ami             = data.aws_ami.aws_linux.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.My-Public-SN-1.id
  user_data       = filebase64("user_data.sh")
  security_groups = [aws_security_group.mySG.id]

  tags = {
    Name = "myWeb1"
  }
}
resource "aws_instance" "myWeb2" {
  ami             = data.aws_ami.aws_linux.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.My-Public-SN-2.id
  user_data       = filebase64("user_data2.sh")
  security_groups = [aws_security_group.mySG.id]

  tags = {
    Name = "myWeb2"
  }
}

resource "aws_eip" "MyEIP1" {
  instance = aws_instance.myWeb1.id
  domain   = "vpc"
}
resource "aws_eip" "MyEIP2" {
  instance = aws_instance.myWeb2.id
  domain   = "vpc"

}

# Resource: aws_lb_target_group
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "ALBTargetGroup" {
  name     = "My-ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id
}

resource "aws_lb_target_group_attachment" "TGAttachement" {
  target_group_arn = aws_lb_target_group.ALBTargetGroup.arn
  target_id        = aws_instance.myWeb1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "TGAttachement2" {
  target_group_arn = aws_lb_target_group.ALBTargetGroup.arn
  target_id        = aws_instance.myWeb2.id
  port             = 80
}

# Resource: aws_lb
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "myALB" {
  name               = "myALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.My-Public-SN-1.id, aws_subnet.My-Public-SN-2.id]
}
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "myALB_LS" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.myALB_LS.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALBTargetGroup.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
