// provider.tf
// AWS Provider 설정 (전역)
provider "aws" {
  region  = var.aws_region    // 전역 변수에서 지정 (예: us-east-1)
  profile = var.aws_profile   // AWS CLI 프로파일 (예: default)
}
