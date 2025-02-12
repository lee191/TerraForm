#
# 1. EC2 인스턴스 생성
# 
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# * Ubuntu 24.04 LTS(ap-northeast-2)
data "aws_ami" "ubuntu2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myinstance" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = var.instance_type
  tags = var.instance_tag
}