output "webapp_public_ip" {
  description = "Stały adres Elastic IP serwera (użyj go w sekrecie SSH_HOST)"
  value       = aws_eip.webapp_eip.public_ip
}

output "webapp_repo_backend_url" {
  description = "URL repozytorium ECR backend"
  value       = aws_ecr_repository.webapp_repo_backend.repository_url
}

output "webapp_repo_frontend_url" {
  description = "URL repozytorium ECR frontend"
  value       = aws_ecr_repository.webapp_repo_frontend.repository_url
}