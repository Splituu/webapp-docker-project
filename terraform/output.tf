output "webapp_public_ip" {
  description = "Stały adres Elastic IP serwera (użyj go w sekrecie SSH_HOST)"
  value       = aws_eip.webapp_eip.public_ip
}
