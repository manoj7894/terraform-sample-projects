# Output the ARN of the DynamoDB table
output "dynamodb_table_arn" {
  value = aws_dynamodb_table.metadata.arn
}