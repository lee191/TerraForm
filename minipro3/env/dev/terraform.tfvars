// env/dev/terraform.tfvars
// dev 환경 변수 값 (필요시 override)

pipeline_name       = "dev-pipeline"
pipeline_role_arn   = "arn:aws:iam::123456789012:role/DevCodePipelineRole"
artifact_bucket     = "my-artifact-bucket-dev"
github_owner        = "dev-github-user"
github_repo         = "dev-repo"
github_branch       = "develop"
github_oauth_token  = "your_dev_github_oauth_token_here"
