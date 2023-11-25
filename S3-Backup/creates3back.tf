# To create S3 bucket with algoritham encryption
# To create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "manoj-9143"
  acl    = "private" # Set the ACL to private for restricted access
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

#Note: To enable the statelock because mutliplr might be work on same code then they might be change the statfile
# So that to avoid the change we will create the dynamodb
# To create dynamodb
resource "aws_dynamodb_table" "metadata" {
  name             = "state-lock"
  billing_mode     = "PAY_PER_REQUEST"   # Another mode is provision
  hash_key         = "LockID"    # partition key of the item
  stream_enabled   = true    # capture the time and order the sequence of data
  stream_view_type = "NEW_AND_OLD_IMAGES"   # it will record the unique sequence number

  attribute {
    name = "LockID"
    type = "S"
  }
}