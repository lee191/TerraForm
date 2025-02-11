# ======================= #
# Terraform
# Provider
# ======================= #

# 1. Terraform
# * https://developer.hashicorp.com/terraform/language/backend/s3
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.86.0"
    }
  }
  backend "s3" {
    bucket = "mybucket-1999-1105"
    key    = "global/s3/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    region = "us-east-2"
  }
}

# Provider
provider "aws" {
  region = "us-east-2"
}

#
# TEST
#
resource "aws_instance" "myEC2" {
  ami           = "ami-088b41ffb0933423f"
  instance_type = "t2.micro"

  tags = {
    Name = "myEC2"
  }
}