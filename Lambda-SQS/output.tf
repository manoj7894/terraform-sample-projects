output "queue_url" {
  value = aws_sqs_queue.example_queue.id
}

output "lambda_function_name" {
  value = aws_lambda_function.html_lambda.function_name
}