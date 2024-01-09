provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_sns_topic" "example_topic" {
  name                        = "example-topic"
  display_name                = "Example Topic"
  fifo_topic                  = false
  content_based_deduplication = false
}

resource "aws_sns_topic_subscription" "example_subscription" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "email"
  endpoint  = "varmapotthuri4@gmail.com" # Replace with your email address
}

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
}

# Convert normal file to Zip file
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "/home/ec2-user/index.js"
  output_path = "${path.module}/index.zip"
}

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
    ],
  })
}


resource "aws_iam_policy" "lambda_policy" {
  name        = "MyLambdaPolicy"
  description = "Policy for My Lambda Function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:Unsubscribe",
          "sns:SetTopicAttributes",
          "sns:RemovePermission",
          "sns:Receive",
          "sns:ListTopics",
          "sns:ListSubscriptionsByTopic",
          "sns:GetTopicAttributes",
          "sns:GetSubscriptionAttributes",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


# Attach a policy to the Lambda execution role if needed
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_cloudwatch_event_rule" "example_rule" {
  name        = "my-rule"
  description = "My EventBridge Rule"

  event_pattern = <<PATTERN
  {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["stopping", "stopped"],
      "instance-id": ["i-069988b6dde85b238"]
    }
  }
  PATTERN
  // Use a rate expression (e.g., trigger the rule every 2 hours)
  schedule_expression = "rate(2 minutes)"
  #schedule_expression = "cron(0/2 * * * ? *)"
}


resource "aws_lambda_permission" "example_lambda_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.example_rule.arn
}

resource "aws_cloudwatch_event_target" "example_target" {
  rule      = aws_cloudwatch_event_rule.example_rule.name
  arn       = aws_lambda_function.html_lambda.arn
  target_id = "example-lambda-target"
}