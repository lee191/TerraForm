// variables.tf (Root Module)
// 전역 변수들을 정의합니다.

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "ami" {
  description = "EC2 인스턴스에 사용할 AMI ID (실제 환경에 맞게 수정)"
  type        = string
  default     = "ami-037f2fa59e7cfbbbb" 
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH 접속용 Key Pair 이름 (없으면 빈 문자열)"
  type        = string
  default     = ""
}

variable "desired_capacity" {
  description = "ASG의 Desired Capacity"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "ASG 최소 인스턴스 수"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "ASG 최대 인스턴스 수"
  type        = number
  default     = 4
}

variable "db_master_username" {
  description = "RDS DB 클러스터 마스터 사용자명"
  type        = string
  default     = "admin"
}

variable "db_master_password" {
  description = "RDS DB 클러스터 마스터 암호"
  type        = string
  default     = "SuperSecurePassword"
}

variable "db_instance_class" {
  description = "RDS 클러스터 인스턴스 클래스"
  type        = string
  default     = "db.t3.medium"
}
