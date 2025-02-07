# ==========================================
# ALB - TG(ASG)
# ==========================================
# 작업 절차
# 1. ALB
# * SG 생성
# * TG 생성
# * LB 생성
# * LB listner 구성
# 2. ASG
# * SG 생성
# * launch template 생성
# * ASG 생성

# ======================================
# 0. 기본 인프라
# ======================================

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
    
  }
}

# ======================================
# 1. ALB
# ======================================

resource "aws_security_group" "myALB_SG" {
  name = "myALB_SG"
  description = "Allow 80/tcp inbound traffic and all outbound traffic"
  vpc_id = data.aws_vpc.default.id


  tags = {
    Name = "myALB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_lb_target_group" "myALB-TG" {
    name = "myALB-TG"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
  
}


resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALB_SG.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB-TG.arn
  }
}

resource "aws_lb_listener_rule" "myALB_listener_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB-TG.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# ======================================
# 2. ASG
# ======================================

resource "aws_security_group" "myASG_SG" {
  name = "myASG_SG"
  description = "Allow 80/tcp inbound traffic and all outbound traffic"
  vpc_id = data.aws_vpc.default.id


  tags = {
    Name = "myASG_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_myASG" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_22_myASG" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_myASG" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


data "aws_ami" "amazon_linux_2023" {
  most_recent      = true
  owners           = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20250203.1-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "myLT" {
  name = "myLT"

  image_id = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  key_name = "mykeypair2"

  vpc_security_group_ids = [aws_security_group.myALB_SG.id]

  user_data = filebase64("user_data.sh")
}

resource "aws_autoscaling_group" "myASG" {
  name                      = "myASG"
  max_size                  = 2
  min_size                  = 2
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_template.myLT.id
  vpc_zone_identifier       = data.aws_subnets.default.ids

  tag {
    key                 = "Name"
    value               = "myASG"
    propagate_at_launch = true
  }
}