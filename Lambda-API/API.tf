# To create the API gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api"
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# To create the API gateway resource
resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "conversion"
}

# To create API gateway method
resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# To create the API gateway integration
resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.my_resource.id
  http_method             = aws_api_gateway_method.my_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.html_lambda.invoke_arn
}

data "aws_caller_identity" "current" {}

# Attach the Lambda function's permission to be invoked by API Gateway
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.my_api.id}/*/${aws_api_gateway_method.my_method.http_method}${aws_api_gateway_resource.my_resource.path}"
}

# To create the API deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  depends_on = [aws_api_gateway_method.my_method, aws_api_gateway_integration.my_integration]

}

# To create API gateway stage
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"

}