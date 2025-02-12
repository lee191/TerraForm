# ============================== #
# 0. Provider
#
# 1. Basic Infra
#   * default vpc
#   * default subnet
#
# 2. ALB - TG(ASG,EC2x2) 
#   * ALB - TG
#       - SG 셍성
#       - TG 생성
#       - ALB 생성
#       - ALB listener 생성
#       - ALB listener rule 생성
#   * ASG
#       - SG 생성
#       - LT 생성
#       - ASG 생성
# ============================== #

#
# 0. Provider
#
provider "aws" {
  region = "us-east-2"
}

#
# 1. Basic Infra
#
# * default vpc
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "default" {
  default = true
}

# * default subnet
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#
# 2. ALB - TG(ASG,EC2x2) 
#
# * ALB - TG
# - SG 셍성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myALB_SG" {
  name        = "myALB_SG"
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myALB_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myALB_SG_80" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "myALB_SG_all" {
  security_group_id = aws_security_group.myALB_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# - TG 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "myALB-TG" {
  name     = "myALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# - ALB 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myALB_SG.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false
}


# - ALB listener 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "myALB_Listener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALB-TG.arn
    }
}
# - ALB listener rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "myALB_Listener_rule" {
  listener_arn = aws_lb_listener.myALB_Listener.arn
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

#
# * ASG
#
# - SG 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myASG_SG" {
  name        = "myASG_SG"
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myASG_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myASG_SG_80" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "myASG_SG_all" {
  security_group_id = aws_security_group.myASG_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# - LT 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
# * Ubuntu 24.04 LTS(us-east-2)
data "aws_ami" "myami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The terraform_remote_state Data Source
# * https://developer.hashicorp.com/terraform/language/backend/s3#data-source-configuration
data "terraform_remote_state" "myTerraformRemoteState" {
  backend = "s3"
  config = {
    bucket = "bucket-1999-1105"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "myLT" {
  name = "myLT"

  image_id = data.aws_ami.myami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.myASG_SG.id]
  # user_data = filebase64("${path.module}/example.sh")
  user_data = base64encode(templatefile("user-data.sh", {
    db_address = data.terraform_remote_state.myTerraformRemoteState.outputs.address,
    db_port = data.terraform_remote_state.myTerraformRemoteState.outputs.port,
    server_port = 80
  }))

}


# - ASG 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
# * target_group_arns
resource "aws_autoscaling_group" "myASG" {
  name                      = "myASG"
  max_size                  = 2
  min_size                  = 2
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = data.aws_subnets.default.ids
  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }

  # 다음 내용은 반드시 점검해야 한다.
  target_group_arns = [aws_lb_target_group.myALB-TG.arn]

  tag {
    key                 = "Name"
    value               = "myASG"
    propagate_at_launch = true
  }
}