// env/prod/terraform.tfvars
pipeline_name       = "prod-pipeline"
pipeline_role_arn   = "arn:aws:iam::123456789012:role/ProdCodePipelineRole"
artifact_bucket     = "my-artifact-bucket-prod"
github_owner        = "prod-github-user"
github_repo         = "prod-repo"
github_branch       = "main"
github_oauth_token  = "your_prod_github_oauth_token_here"
