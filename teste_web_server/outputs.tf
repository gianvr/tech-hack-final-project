output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "instance_name" {
  value = aws_instance.web_server.tags.Name
}