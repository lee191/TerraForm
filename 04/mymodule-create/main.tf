provider "aws" {
  region = "ap-northeast-2"
}

# net module 실행
module "net" {
  source = "./modules/net"

}

# ec2 module 실행
module "ec2" {
  source = "./modules/ec2"

  vpc_id = module.net.vpc_id
  cidr_ipv4 = module.net.myPublicSubnet_cidr_block
  subnet_id = module.net.myPublicSubnet_id
}