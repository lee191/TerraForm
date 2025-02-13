###############################
# Provider 및 모듈 호출 (Root)
###############################
provider "aws" {
  region = var.aws_region
}

# 네트워크(VPC, Subnet, IGW, Route Table) 구성 모듈 호출
module "net" {
  source = "./modules/net"
  # modules/net/variables.tf 에 정의한 기본값 사용 (원하는 경우 override 가능)
}

# 웹 서버(EC2, ASG, 보안그룹, Launch Template) 구성 모듈 호출
module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.net.vpc_id            # 네트워크 모듈에서 생성된 VPC ID
  public_subnet_ids = module.net.public_subnet_ids # Public Subnet ID 리스트 (ASG 배포용)
  ami               = var.ami                      # EC2에 사용할 AMI
  instance_type     = var.instance_type            # EC2 인스턴스 타입
  key_name          = var.key_name                 # SSH 접속용 Key Pair (없으면 "")
  desired_capacity  = var.desired_capacity         # ASG Desired Capacity
  min_size          = var.min_size                 # ASG 최소 인스턴스 수
  max_size          = var.max_size                 # ASG 최대 인스턴스 수
}

###############################
# ELB (Application Load Balancer) 구성
###############################
# ELB 접근을 위한 보안 그룹
resource "aws_security_group" "elb_sg" {
  name        = "miniproject-alb-sg"
  description = "ALB SG: Allow HTTP access"
  vpc_id      = module.net.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB 생성 (Public Subnet에 생성)
resource "aws_lb" "app_lb" {
  name               = "MiniProject-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = module.net.public_subnet_ids

  tags = {
    Name = "MiniProject-ALB"
  }
}

# ALB Target Group 생성 (웹 서버로 트래픽 전달)
resource "aws_lb_target_group" "app_tg" {
  name     = "MiniProject-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.net.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }
}

# ALB Listener 생성: HTTP 요청 시 Target Group으로 전달
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

###############################
# RDS MySQL Cluster (Aurora MySQL) 구성
###############################
# DB 서브넷 그룹 생성 (Private Subnet 사용)
resource "aws_db_subnet_group" "db_subnet" {
  name       = "miniproject-dbsubnetgrou"
  subnet_ids = module.net.private_subnet_ids

  tags = {
    Name = "miniproject-dbsubnetgrou"
  }
}

# DB 클러스터용 보안 그룹: 웹 서버에서 MySQL(3306) 접근 허용
resource "aws_security_group" "db_sg" {
  name        = "miniproject-db-sg"
  vpc_id      = module.net.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.ec2.web_security_group_id] # EC2 모듈에서 생성한 웹 SG 사용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Aurora MySQL 클러스터 생성
resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier     = "miniproject-db-cluster"
  engine                 = "aurora-mysql"
  master_username        = var.db_master_username
  master_password        = var.db_master_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "MiniProject-DBCluster"
  }
}

# 클러스터에 속하는 DB 인스턴스 2개 생성
resource "aws_rds_cluster_instance" "db_instances" {
  count               = 2
  identifier          = "miniproject-db-${count.index}"
  cluster_identifier  = aws_rds_cluster.db_cluster.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.db_cluster.engine
  engine_version      = aws_rds_cluster.db_cluster.engine_version
  publicly_accessible = false

  tags = {
    Name = "MiniProject-DBInstance-${count.index}"
  }
}
