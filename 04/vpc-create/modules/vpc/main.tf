###################################################
# 1. VPC 생성
# 2. Subnet 생성
###################################################

#
# 1. VPC 생성
#
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  tags = var.vpc_tag
}

#
# 2. Subnet 생성
#
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.subnet_cidr
  tags = var.subnet_tag
}