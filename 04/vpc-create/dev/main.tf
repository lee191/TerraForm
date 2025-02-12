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
}

# module myec2
module "myec2" {
  source = "../modules/ec2"
}