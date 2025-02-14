// variables.tf
// 전역 변수 정의
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI 프로파일"
  type        = string
  default     = "default"
}

// 모듈 호출에 사용할 변수 (전역 기본값을 정의)
variable "pipeline_name" {
  description = "CI/CD 파이프라인 이름"
  type        = string
  default     = "my-ci-cd-pipeline"
}

variable "pipeline_role_arn" {
  description = "CI/CD 파이프라인 역할 ARN"
  type        = string
  default     = "arn:aws:iam::123456789012:role/CodePipelineRole"
}

variable "artifact_bucket" {
  description = "Artifact 저장소 S3 버킷 이름"
  type        = string
  default     = "my-artifact-bucket"
}

variable "github_owner" {
  description = "GitHub 소유자"
  type        = string
  default     = "my-github-user"
}

variable "github_repo" {
  description = "GitHub 저장소 이름"
  type        = string
  default     = "my-repo"
}

variable "github_branch" {
  description = "GitHub 브랜치"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "GitHub OAuth 토큰 (sensitive)"
  type        = string
  sensitive   = true
  default     = "your_github_oauth_token_here"
}
