provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "fearlessrd.fearless.tech-coffee"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "fearless-coffee-terraform-state-locktable"
    acl = "bucket-owner-full-control"
  }
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "fearlessrd.fearless.tech-coffee"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "S3 Remote Terraform State Store for fearless coffee"
  }
}
resource "aws_dynamodb_table" "terraform-state-locktable" {
  name           = "fearless-coffee-terraform-state-locktable"
  hash_key = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table for fearless coffee"
  }
}
