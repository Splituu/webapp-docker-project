output "ubuntu_ami_id" {
  value = aws_instance.webapp.public_ip
}