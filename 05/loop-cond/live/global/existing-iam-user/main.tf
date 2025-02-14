provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "create_user" {
  # Make sure to update this to your own user name!
  for_each = toset(var.username)
  name = each.value
}

