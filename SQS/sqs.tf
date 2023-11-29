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

  # Specify the queue type (Standard or FIFO)
  fifo_queue = false # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}


# How to create FIFO SQS without KMS
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-fifo-queue.fifo"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]
  content_based_deduplication = true  # Enable content-based deduplication

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  # Specify the queue type (Standard or FIFO)
  fifo_queue = true # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}


# How to create Standard SQS with KMS
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-1"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]
  kms_master_key_id          = aws_kms_key.my_kms_key.arn  # ARN of the KMS key

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  # Specify the queue type (Standard or FIFO)
  fifo_queue = false # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}



# How to create FIFO SQS with KMS
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-fifo-queue.fifo"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]
  content_based_deduplication = true  # Enable content-based deduplication
  kms_master_key_id          = aws_kms_key.my_kms_key.arn  # ARN of the KMS key

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  # Specify the queue type (Standard or FIFO)
  fifo_queue = true # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}



# How to create Standard SQS along with KMS, Dead-letter and Redrive Policy
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-1"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]
  kms_master_key_id          = aws_kms_key.my_kms_key.arn  # ARN of the KMS key

  # Optional Redrive Policy (for Dead Letter Queue)
  redrive_policy = jsonencode({
    deadLetterTargetArn    = aws_sqs_queue.example_dead_letter_queue.arn
    maxReceiveCount        = 5
  })

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  # Specify the queue type (Standard or FIFO)
  fifo_queue = false # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}

# Optional: Create a Dead Letter Queue
resource "aws_sqs_queue" "example_dead_letter_queue" {
  name = "example-dead-letter-queue"
}


# How to create FIFO SQS along with KMS, Dead-letter and Redrive Policy
resource "aws_sqs_queue" "example_queue" {
  name                       = "example-fifo-queue.fifo"
  delay_seconds              = 60    # No processer cant access the message from qube upto 60 seconds
  message_retention_seconds  = 86400 # how many days or seconds message should be in qube
  receive_wait_time_seconds  = 10    # when should receiver get message
  visibility_timeout_seconds = 30    # The visibility timeout for the queue [message cant appear when someone acces the message at same time it will visiable after commplete visual time out]
  content_based_deduplication = true  # Enable content-based deduplication
  kms_master_key_id          = aws_kms_key.my_kms_key.arn  # ARN of the KMS key

  # Optional Redrive Policy (for Dead Letter Queue)
  redrive_policy = jsonencode({
    deadLetterTargetArn    = aws_sqs_queue.example_dead_letter_queue.arn
    maxReceiveCount        = 5
  })

  # Optional Queue Tags
  tags = {
    Environment = "Production"
    Department  = "IT"
  }

  # Specify the queue type (Standard or FIFO)
  fifo_queue = true # Set to true for FIFO queue, false for Standard queue

  # Specify the maximum message size in bytes (valid values: 1024 bytes to 256 KB for Standard, 1 KB to 256 KB for FIFO)
  max_message_size = 1024 # 256 KB  size of message Should be between 1 KB and 256 KB.

  # Other configurations...
}

# Optional: Create a Dead Letter Queue
resource "aws_sqs_queue" "example_dead_letter_queue" {
  name = "example-dead-letter-queue"
}




#aws sqs send-message --region ap-south-1 --endpoint-url https://sqs.ap-south-1.amazonaws.com/ --queue-url https://sqs.ap-south-1.amazonaws.com/254669244016/Queue-01 --message-body "hello from Ec2 over the internet"


#aws sqs send-message --region ap-south-1 --endpoint-url https://vpce-00eb6c4c3146a11b6-xat3iv26.sqs.ap-south-1.vpce.amazonaws.com/ --queue-url https://sqs.ap-south-1.amazonaws.com/254669244016/Queue-01 --message-body "hello from Ec2 over the VPC"


