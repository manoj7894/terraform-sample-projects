# To get the message in SQS when we upload the file in s3 bucket
# provider details
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "manoj-9020"
}

# To create the s3 bucket ownership_controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# To create ss3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# To create s3 bucket ACL permission
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}

data "aws_caller_identity" "current" {}

# How to create Standard SQS without KMS
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-queue"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[{
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage"
          ],
          "Resource":  "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:example-queue",
          "Condition":{
              "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.my_bucket.arn}"}
          }
      }]
  }
  POLICY

  # Specify the queue type (Standard or FIFO)
  fifo_queue = false # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}

resource "aws_s3_bucket_notification" "s3_notif" {
  bucket = aws_s3_bucket.my_bucket.id

  queue {
    queue_arn = aws_sqs_queue.example_queue.arn

    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:Delete",
      "s3:ObjectRemoved:DeleteMarkerCreated",
    ]

  }
}



# To get the message in SQS when we stop the instance

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_caller_identity" "current" {}

# How to create Standard SQS without KMS
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-queue"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[{
          "Effect": "Allow",
          "Principal": "*",
          "Action": "sqs:SendMessage",
          "Resource":  "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:example-queue"
      }]
  }
  POLICY

  # Specify the queue type (Standard or FIFO)
  fifo_queue = false # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}

resource "aws_cloudwatch_event_rule" "example_rule" {
  name        = "my-rule"
  description = "My EventBridge Rule"

  event_pattern = <<PATTERN
  {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["stopping", "stopped"]
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "example_target" {
  rule      = aws_cloudwatch_event_rule.example_rule.name
  arn       = aws_sqs_queue.example_queue.arn # Replace with your SNS topic ARN
  target_id = "example-target-id"
}

