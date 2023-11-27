output "guacamole_information" {
    value = "hostname=guacamole address=${var.guacamole_private_ip}"
}

output "database_information" {
    value = "hostname=database address=${var.database_private_ip}"
}

output "web_server_information" {
    value = "hostname=web_server address=${var.web_server_private_ip}"
}

output "acess_guacamole" {
    value = "http://${module.guacamole.guacamole_public_ip}:8080/guacamole"
}

output "acess_zabbix" {
    value = "http://${module.zabbix.zabbix_public_ip}/zabbix"
}

output "acess_web_server" {
    value = "http://${module.web_server.web_server_public_ip}"
}
