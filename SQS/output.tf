output "queue_url" {
  value = aws_sqs_queue.example_queue.id
}

output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.sqs_endpoint.id
}

output "vpc_endpoint_dns_name" {
  value = "sqs.ap-south-1.amazonaws.com"
}


output "vpc_endpoint_service_name" {
  value = aws_vpc_endpoint.sqs_endpoint.service_name
}

output "vpc_endpoint_subnet_ids" {
  value = aws_vpc_endpoint.sqs_endpoint.subnet_ids
}


