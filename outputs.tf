output "guacamole_private_ip" {
    value = "hostname=guacamole address=${var.guacamole_private_ip}"
}

output "database_private_ip" {
    value = "hostname=database address=${var.database_private_ip}"
}

output "web_server_private_ip" {
    value = "hostname=web_server address=${var.web_server_private_ip}"
}