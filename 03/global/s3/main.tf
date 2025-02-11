# ============================ #
# Provider 설정
# S3 bucket 생성
# DynamoDB 생성
# ============================ #

# 1. Provider 설정
provider "aws" {
  region = "us-east-2"
}

# 2. S3 bucket 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mybucket-1999-1105"

  force_destroy = true
  tags = {
    Name        = "terraform_state"
  }
}

# >>>>>>> 추가 비용 발생 <<<<<<< #
# # Resource: aws_s3_bucket_server_side_encryption_configuration
# # * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
# resource "aws_kms_key" "myKMSkey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "myS3bucket_enc" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.myKMSkey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# # Resource: aws_s3_bucket_versioning
# # * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# resource "aws_s3_bucket_versioning" "myS3bucket_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# 3. DynamoDB 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "terraform-locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"    # PAY_PER_REQUEST, PROVISIONED(default)
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"  # S(String), N(number), B(binary)
  }

  tags = {
    Name        = "terraform-locks"
  }
}            