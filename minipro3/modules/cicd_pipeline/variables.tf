// modules/cicd_pipeline/variables.tf
// 모듈에서 사용할 변수 정의

variable "pipeline_name" {
  description = "CI/CD 파이프라인 이름"
  type        = string
}

variable "pipeline_role_arn" {
  description = "파이프라인 역할 ARN"
  type        = string
}

variable "artifact_bucket" {
  description = "Artifact 저장소 S3 버킷 이름"
  type        = string
}

variable "github_owner" {
  description = "GitHub 소유자"
  type        = string
}

variable "github_repo" {
  description = "GitHub 저장소 이름"
  type        = string
}

variable "github_branch" {
  description = "GitHub 브랜치"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub OAuth 토큰"
  type        = string
  sensitive   = true
}
