# To create the Lambda function
resource "aws_lambda_function" "html_lambda" {
  filename         = "index.zip"
  function_name    = "MyLambdaFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  layers           = [aws_lambda_layer_version.example_layer.arn]
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_cloudwatch_log_group.lambda_log_group,
  ]

  environment {
    variables = {
      KEY1 = "value1",
      KEY2 = "value2",
      SECRET_NAME = aws_secretsmanager_secret.example_secret.name
    }
  }
}

# Convert normal file to Zip file
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "/home/ec2-user/index.js"
  output_path = "${path.module}/index.zip"
}

# Convert normal file to Zip file for layer
data "archive_file" "lambda_package1" {
  type        = "zip"
  source_file = "/home/ec2-user/index1.js"
  output_path = "${path.module}/index1.zip"
}

# To create lambda layer
resource "aws_lambda_layer_version" "example_layer" {
  layer_name  = "layer-1"
  description = "My Lambda layer"

  filename = data.archive_file.lambda_package1.output_path
  source_code_hash = data.archive_file.lambda_package1.output_base64sha256

  compatible_runtimes = ["nodejs14.x"] # Adjust to the runtime you are using
}

# To create the cloud watch to see logs
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/MyLambdaFunction" # Adjust the name to match your Lambda function's name
  retention_in_days = 14
}

# To create the lambda policy role for lambda along with secret and read access
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
        "Effect": "Allow",
        "Principal": {
          "Service": "secretsmanager.amazonaws.com"
        },
        "Action": [
		    "secretsmanager:GetResourcePolicy",
			  "secretsmanager:GetSecretValue",
			  "secretsmanager:DescribeSecret",
			  "secretsmanager:ListSecretVersionIds"
	    ],
        "Resource": "${aws_secretsmanager_secret.example_secret.arn}"
       }
    ],
  })
}

# To create cloud policy role for cloud watch
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