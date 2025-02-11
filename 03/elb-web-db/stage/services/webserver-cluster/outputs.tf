output "myALB_DNS_Name" {
  value = aws_lb.myALB.dns_name
  description = "ALB DNS name"
}
