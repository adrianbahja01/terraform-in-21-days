resource "aws_dynamodb_table" "tf-lock-state" {
  name           = var.tfdynamodb_name
  read_capacity  = "5"
  write_capacity = "5"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = var.tfdynamodb_name
  }
}

resource "aws_s3_bucket" "tf-remote-state" {
  bucket = var.tfbucket_name
  tags = {
    "Name" = var.tfbucket_name
  }
}
