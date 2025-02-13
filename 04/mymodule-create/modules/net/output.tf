output "vpc_id" {
  value = aws_vpc.myVPC.id
}

output "myPublicSubnet_id" {
  value = aws_subnet.myPublicSubnet.id
}

output "myPublicSubnet_cidr_block" {
  value = aws_subnet.myPublicSubnet.cidr_block
}