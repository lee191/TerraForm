// modules/ec2/outputs.tf
// 모듈에서 생성된 웹 서버 관련 주요 리소스 정보를 출력합니다.

output "web_security_group_id" {
  description = "웹 서버용 보안 그룹 ID"
  value       = aws_security_group.web_sg.id
}

output "launch_template_id" {
  description = "웹 서버 Launch Template ID"
  value       = aws_launch_template.web_lt.id
}

output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.web_asg.id
}
