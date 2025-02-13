// modules/ec2/variables.tf
// EC2 및 ASG 구성에 필요한 변수들을 정의합니다.

variable "vpc_id" {
  description = "네트워크 모듈에서 생성된 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "EC2 인스턴스를 배포할 Public 서브넷 ID 리스트"
  type        = list(string)
}

variable "ami" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
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
