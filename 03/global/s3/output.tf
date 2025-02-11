output "s3_buckt_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "S3 bucket arn"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform-locks.name
  description = "Dynamodb Table name"
}