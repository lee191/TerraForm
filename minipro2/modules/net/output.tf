// modules/net/outputs.tf
// 네트워크 모듈에서 생성된 주요 리소스의 ID를 출력합니다.

output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "생성된 Public 서브넷 ID 리스트"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "생성된 Private 서브넷 ID 리스트"
  value       = aws_subnet.private[*].id
}
