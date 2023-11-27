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
