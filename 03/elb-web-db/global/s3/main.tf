# ======================= #
# 0. Provider
# 1. S3 bucket 생성
# 2. DynamoDB Table 생성
# ======================= #

# 0. Provider
provider "aws" {
  region = "us-east-2"
}

# 1. S3 bucket 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
# * forc_destrory
resource "aws_s3_bucket" "mybucket" {
  bucket = "bucket-1999-1105"
  force_destroy = true


  tags = {
    Name        = "mybucket"
  }
}

# # * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
# resource "aws_s3_bucket_acl" "" {
#   bucket = aws_s3_bucket.mybucket.id
#   acl    = "private"
# }

# # * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
# resource "aws_s3_bucket_versioning" "mybucket_versioning" {
#   bucket = aws_s3_bucket.mybucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
# resource "aws_kms_key" "myKMSkey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "mybucket_encryption" {
#   bucket = aws_s3_bucket.mybucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.myKMSkey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }



# 2. DynamoDB Table 생성
# * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "myDyDB" {
  name           = "myDyDB"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

  tags = {
    Name        = "myDyDB"
  }
}