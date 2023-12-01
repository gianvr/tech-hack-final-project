variable "guacamole_private_ip" {
  type = string
  default = "172.31.1.2"
}

variable "database_private_ip" {
  type = string
  default = "172.31.17.2"

}

variable "web_server_private_ip" {
  type = string
  default = "172.31.1.3"
}

variable "zabbix_private_ip" {
  type = string
  default = "172.31.1.4"
}

// Testing Enviroment Variables

variable "testing_guacamole_private_ip" {
  type = string
  default = "172.31.1.5"
}

variable "testing_database_private_ip" {
  type = string
  default = "172.31.17.6"

}

variable "testing_web_server_private_ip" {
  type = string
  default = "172.31.1.7"
}

variable "testing_zabbix_private_ip" {
  type = string
  default = "172.31.1.8"
}
