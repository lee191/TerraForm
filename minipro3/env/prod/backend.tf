// env/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-backend-prod"
    key            = "terraform/state/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-prod"
    encrypt        = true
  }
}
