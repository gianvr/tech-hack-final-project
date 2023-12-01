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

// Testing Enviroment Outputs

output "testing_guacamole_information" {
    value = "hostname=guacamole address=${var.testing_guacamole_private_ip}"
}

output "testing_database_information" {
    value = "hostname=database address=${var.testing_database_private_ip}"
}

output "testing_web_server_information" {
    value = "hostname=web_server address=${var.testing_web_server_private_ip}"
}

output "testing_acess_guacamole" {
    value = "http://${module.testing_guacamole.guacamole_public_ip}:8080/guacamole"
}

output "testing_acess_zabbix" {
    value = "http://${module.testing_zabbix.zabbix_public_ip}/zabbix"
}

output "testing_acess_web_server" {
    value = "http://${module.testing_web_server.web_server_public_ip}"
}
