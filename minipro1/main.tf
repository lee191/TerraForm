# =========================================== #
# 1. 인프라 구성
#   * vpc 생성
#   * IGW 생성 및 연결
#   * Public SN 생성
#   * Public RT 생성
#   * Public RT 연결
# 2. EC2 인스턴스 생성
#   * SG 생성       
#   * AMI Data Source 설정
#   * SSH Key 생성
#   * EC2 생성
#       - AMI
#       - SSH Key
#       - User Data (docker 설치)
# 3. PC에서 EC2 연결 설정
# =========================================== #

# ========================
# 1. 인프라 구성
# ========================
# 1) vpc 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# * enable_dns_hostnames
resource "aws_vpc" "myVPC"{
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# 2) IGW 생성 및 연결
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# 3) Public SN 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# * availability_zone
# * map_public_ip_on_launch
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSN"
  }
}

# 4) Public RT 생성 및 연결
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}
# Resource: aws_route_table_association
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "myRTassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

# ========================
# 2. EC2 인스턴스 생성
# ========================
# 1) SG 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# 2) AMI Data Source 설정
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# * Amazon Linux 2023 AMI
data "aws_ami" "amazonLinux2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.*.1-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

# 3) SSH Key 생성
# >>>>>>>>>>>> 사용자가 반드시 해야 하는 역할 <<<<<<<<<<<<<<
# $ ssh-keygen -t rsa
# Generating public/private rsa key pair.
# Enter file in which to save the key (/home/tf/.ssh/id_rsa): /home/tf/.ssh/devkey  <-- 키페어 저장 위치
# Enter passphrase (empty for no passphrase):   <-- <ENTER> 입력
# Enter same passphrase again:                  <-- <ENTER> 입력
# Your identification has been saved in /home/tf/.ssh/devkey
# Your public key has been saved in /home/tf/.ssh/devkey.pub
# The key fingerprint is:
# SHA256:xsSvkxdOQrj3Ohl1PwzzmiWO4wFFt7mT8CLSVKkdOuk tf@main.example.com
# The key's randomart image is:
# +---[RSA 3072]----+
# |          o..    |
# |       o oo. o   |
# |      . ==o.o    |
# |       B=ooo+o   |
# |      o.So=.=*   |
# |       +EX o..*  |
# |        +o=o = . |
# |        o+o.+    |
# |        .o..     |
# +----[SHA256]-----+

# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "devkeypair" {
  key_name   = "devkeypair"
  public_key = file("~/.ssh/devkey.pub")
}


# 4) EC2 생성
#   - AMI
#   - SSH Key
#   - User Data (docker 설치)
# * ami
# * key_name
# * subnet_id
# * vpc_security_group_ids
# * user_data
# * provisioner - local-exec
#   - https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
#   - templatefile()
#     - https://developer.hashicorp.com/terraform/language/functions/templatefile

resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.amazonLinux2023.id
  instance_type = "t2.micro"

  # SSH key
  key_name = "devkeypair"

  # subnet_id
  subnet_id = aws_subnet.myPubSN.id

  # vpc_security_group_ids
  vpc_security_group_ids = [ aws_security_group.mySG.id ]

  # user_data
  user_data_replace_on_change = true
  user_data= filebase64("user_data.tpl") 

  # provisioner - local-exec
  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
        hostname = self.public_ip,
        user = "ec2-user"
        identifyfile = "~/.ssh/devkey"
    })
    interpreter = [ "bash", "-c" ]
    # interpreter = ["Powershell", "-Command"]
  }

  tags = {
    Name = "myEC2"
  }
}
# ========================
# 3. PC에서 EC2 연결 설정
# ========================
