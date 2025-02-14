// modules/cicd_pipeline/outputs.tf
// 모듈 출력 값 정의

output "pipeline_id" {
  description = "생성된 CodePipeline의 ID"
  value       = aws_codepipeline.pipeline.id
}
