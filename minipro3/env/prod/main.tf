// env/prod/main.tf
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
