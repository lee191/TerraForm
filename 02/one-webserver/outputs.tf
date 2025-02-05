output "public_ip" {
  value       = aws_instance.myweb.public_ip
  description = "The public IP of the Instance"
}

output "public_dns_name" {
  value = aws_instance.myweb.public_dns
  description = "The public DNS_NAME of the Instance"
}

