// env/dev/main.tf
// dev 환경에서 모듈 호출 및 환경 전용 리소스 구성

module "cicd_pipeline" {
  source              = "../../modules/cicd_pipeline"
  pipeline_name       = var.pipeline_name
  pipeline_role_arn   = var.pipeline_role_arn
  artifact_bucket     = var.artifact_bucket
  github_owner        = var.github_owner
  github_repo         = var.github_repo
  github_branch       = var.github_branch
  github_oauth_token  = var.github_oauth_token
}

// 추가로 dev 환경 전용 리소스를 여기서 정의 가능
