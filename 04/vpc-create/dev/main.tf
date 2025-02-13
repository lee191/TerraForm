###############################################################
# 0. Provider
# 1. Module 사용 테스트
###############################################################

#
# 0. Provider
#
provider "aws" {
  region = "ap-northeast-2"
}

#
# 1. Module 사용 테스트
#

# module myvpc
module "myvpc" {
  source = "../modules/vpc"

  vpc_cidr = "192.168.10.0/24"
  subnet_cidr = "192.168.10.0/25"
}

# module myec2
module "myec2" {
  source = "../modules/ec2"

  instance_count = 1
  subnet_id = module.myvpc.subnet_id
  instance_type = "t3.micro"
}
