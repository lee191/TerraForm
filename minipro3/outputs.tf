// outputs.tf
// 전역 출력 값 정의
output "pipeline_id" {
  description = "생성된 CI/CD 파이프라인의 ID"
  value       = module.cicd_pipeline.pipeline_id
}

output "project_name" {
  description = "프로젝트 이름"
  value       = "minipro3"
}
