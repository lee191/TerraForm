// output.tf (Root Module)
// 최종적으로 생성된 주요 리소스들의 정보를 출력합니다.

output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.net.vpc_id
}

output "public_subnet_ids" {
  description = "생성된 Public 서브넷 ID 리스트"
  value       = module.net.public_subnet_ids
}

output "private_subnet_ids" {
  description = "생성된 Private 서브넷 ID 리스트"
  value       = module.net.private_subnet_ids
}

output "alb_dns_name" {
  description = "Application Load Balancer의 DNS 이름"
  value       = aws_lb.app_lb.dns_name
}

output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = module.ec2.asg_id
}

output "db_cluster_endpoint" {
  description = "RDS DB 클러스터 엔드포인트"
  value       = aws_rds_cluster.db_cluster.endpoint
}
