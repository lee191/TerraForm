// modules/ec2/main.tf
// 웹 서버(EC2)의 보안 그룹, Launch Template, Auto Scaling Group을 생성합니다.

###############################
# 1. 웹 서버용 보안 그룹 생성
###############################
resource "aws_security_group" "web_sg" {
  name        = "mini-project-web-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MiniProject-Web-SG"
  }
}

###############################
# 2. Launch Template 생성
###############################
resource "aws_launch_template" "web_lt" {
  name_prefix   = "MiniProject-Web-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  # 사용자 데이터(User Data) 스크립트:
  # - 시스템 업데이트 및 httpd, PHP, php-mysqlnd 설치
  # - httpd 시작 및 부팅 시 자동 실행 설정
  # - 간단한 phpinfo() 페이지 생성
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd php php-mysqlnd
    systemctl start httpd
    systemctl enable httpd
    echo "<?php phpinfo(); ?>" > /var/www/html/index.php
  EOF
  )

  network_interfaces {
    # Public IP 자동 할당 및 웹 보안 그룹 적용
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "MiniProject-Web-LaunchTemplate"
  }
}

###############################
# 3. Auto Scaling Group 생성 (웹 서버 ASG)
###############################
resource "aws_autoscaling_group" "web_asg" {
  name                = "miniproject-web-sg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  # 헬스 체크 설정 (여기서는 EC2 기본 헬스 체크 사용)
  health_check_type         = "EC2"
  health_check_grace_period = 300

tag {
    key                 = "Name"
    value               = "miniproject-web-sg"
    propagate_at_launch = true
    }

}
