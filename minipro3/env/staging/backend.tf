// env/staging/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-backend-staging"
    key            = "terraform/state/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-staging"
    encrypt        = true
  }
}
