// modules/cicd_pipeline/main.tf
// CI/CD 파이프라인 리소스 정의 (AWS CodePipeline)
// 주의: 실제 운영 환경에서는 추가 단계(Build, Deploy 등)를 포함하여 구성해야 합니다.

resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = var.pipeline_role_arn

  artifact_store {
    type     = "S3"
    location = var.artifact_bucket
  }

  // Source 단계: GitHub에서 소스 코드를 가져옵니다.
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  // Build 단계: CodeBuild를 사용하여 소스 코드를 빌드합니다.
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  // 추가 단계(Deploy 등)를 필요에 따라 구성할 수 있습니다.
}
