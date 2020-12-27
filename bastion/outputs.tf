output "aws_private_key" {
  value = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}

output "instance" {
  value = aws_instance.bastion
}
