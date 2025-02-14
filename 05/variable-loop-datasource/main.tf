provider "aws" {
    region = var.region
}

resource "aws_vpc" "main" {
    cidr_block = "190.160.0.0/16"
    instance_tenancy = "default"
    tags = {
        Name = "Main"
        Location = "Seoul"
    }
}

data "aws_availability_zone" "asz" {}

resource "aws_subnet" "subnets" {
    count = "${length(data.aws_availability_zone.asz.names)}"

    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${element(var.subnet_cidrs, count.index)}"

    tags = {
        Name = "Subnet-${count.index + 1}"
    }
}