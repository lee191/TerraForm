// env/dev/variables.tf
// dev 환경 전용 변수 정의

variable "pipeline_name" {
  description = "dev 환경 CI/CD 파이프라인 이름"
  type        = string
  default     = "dev-pipeline"
}

variable "pipeline_role_arn" {
  description = "dev 환경 파이프라인 역할 ARN"
  type        = string
  default     = "arn:aws:iam::123456789012:role/DevCodePipelineRole"
}

variable "artifact_bucket" {
  description = "dev 환경 Artifact S3 버킷"
  type        = string
  default     = "my-artifact-bucket-dev"
}

variable "github_owner" {
  description = "GitHub 소유자"
  type        = string
  default     = "dev-github-user"
}

variable "github_repo" {
  description = "GitHub 저장소 이름"
  type        = string
  default     = "dev-repo"
}

variable "github_branch" {
  description = "GitHub 브랜치"
  type        = string
  default     = "develop"
}

variable "github_oauth_token" {
  description = "GitHub OAuth 토큰"
  type        = string
  sensitive   = true
}
