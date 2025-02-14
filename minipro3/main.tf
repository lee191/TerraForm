// main.tf
// 최상위에서 공통 리소스나 모듈 호출을 정의
//
// 예: modules/cicd_pipeline 모듈 호출 (환경별 구성은 env/* 디렉토리에서 진행)
module "cicd_pipeline" {
  source = "./modules/cicd_pipeline"
  
  pipeline_name       = var.pipeline_name
  pipeline_role_arn   = var.pipeline_role_arn
  artifact_bucket     = var.artifact_bucket
  github_owner        = var.github_owner
  github_repo         = var.github_repo
  github_branch       = var.github_branch
  github_oauth_token  = var.github_oauth_token
}
