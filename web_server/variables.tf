variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "web_server_private_ip" {
    type = string
}

variable "zabbix_private_ip" {
    type = string
}

variable "database_private_ip" {
    type = string
}

variable "guacamole_private_ip" {
    type = string
}

variable "environment_key" {
    type = string
}

variable "ec2_iam_instance_profile" {
    type = string
}