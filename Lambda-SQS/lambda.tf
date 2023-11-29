# To create the Lambda function
resource "aws_lambda_function" "html_lambda" {
  filename         = "index.zip"
  function_name    = "MyLambdaFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.lambda_log_group,
  ]

  environment {
    variables = {
      KEY1 = "value1",
      KEY2 = "value2"
    }
  }
}

# Convert normal file to Zip file
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "/home/ec2-user/index.js"
  output_path = "${path.module}/index.zip"
}

# To create the cloud watch to see logs
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/MyLambdaFunction" # Adjust the name to match your Lambda function's name
  retention_in_days = 14
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
      {
        "Action": [
            "sqs:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
            "Resource": "*"
      }
    ],
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "MyLambdaPolicy" # Name for the policy
  description = "Policy for My Lambda Function"

  # Define the policy document with the necessary permissions
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach a policy to the Lambda execution role if needed
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Attach the necessary policy to the Lambda execution role (adjust permissions as needed)
resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}


# Create an event source mapping between SQS and Lambda
resource "aws_lambda_event_source_mapping" "example_event_mapping" {
  event_source_arn = aws_sqs_queue.example_queue.arn
  function_name    = aws_lambda_function.html_lambda.function_name
  enabled          = true
  batch_size        = 1  # Number of messages to process in a single batch
}