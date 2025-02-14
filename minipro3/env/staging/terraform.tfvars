// env/staging/terraform.tfvars
pipeline_name       = "staging-pipeline"
pipeline_role_arn   = "arn:aws:iam::123456789012:role/StagingCodePipelineRole"
artifact_bucket     = "my-artifact-bucket-staging"
github_owner        = "staging-github-user"
github_repo         = "staging-repo"
github_branch       = "staging"
github_oauth_token  = "your_staging_github_oauth_token_here"
