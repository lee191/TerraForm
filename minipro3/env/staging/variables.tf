// env/staging/variables.tf
variable "pipeline_name" {
  description = "staging 환경 CI/CD 파이프라인 이름"
  type        = string
  default     = "staging-pipeline"
}

variable "pipeline_role_arn" {
  description = "staging 환경 파이프라인 역할 ARN"
  type        = string
  default     = "arn:aws:iam::123456789012:role/StagingCodePipelineRole"
}

variable "artifact_bucket" {
  description = "staging 환경 Artifact S3 버킷"
  type        = string
  default     = "my-artifact-bucket-staging"
}

variable "github_owner" {
  description = "GitHub 소유자"
  type        = string
  default     = "staging-github-user"
}

variable "github_repo" {
  description = "GitHub 저장소 이름"
  type        = string
  default     = "staging-repo"
}

variable "github_branch" {
  description = "GitHub 브랜치"
  type        = string
  default     = "staging"
}

variable "github_oauth_token" {
  description = "GitHub OAuth 토큰"
  type        = string
  sensitive   = true
}
