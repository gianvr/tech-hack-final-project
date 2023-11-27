output "guacamole_instance_id" {
    value = aws_instance.guacamole.id
}

output "guacamole_network_interface_id" {
    value = aws_instance.guacamole.primary_network_interface_id
}

output "environment_key_name" {
    value = aws_key_pair.environment_key_pair.key_name
}

output "guacamole_public_ip" {
    value = aws_instance.guacamole.public_ip
}
