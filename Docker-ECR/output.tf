output "repository_uri" {
  value = aws_ecr_repository.demo-repository.repository_url
}

output "ecr_username" {
  value = data.aws_ecr_registry.ecr.registry_id
}