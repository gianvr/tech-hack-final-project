module "guacamole" {
  source = "./guacamole"
  vpc_id = module.vpc.vpc_id_project
  public_subnet_id = module.vpc.subnet_public_id
  database_private_ip = var.database_private_ip
  web_server_private_ip = var.web_server_private_ip
  zabbix_private_ip = var.zabbix_private_ip
  guacamole_private_ip = var.guacamole_private_ip
}

module "database" {
  source = "./database"
  guacamole_network_interface_id = module.guacamole.guacamole_network_interface_id
  vpc_id = module.vpc.vpc_id_project
  zabbix_private_ip = var.zabbix_private_ip
  guacamole_private_ip = var.guacamole_private_ip
  web_server_private_ip = var.web_server_private_ip
  database_private_ip = var.database_private_ip
  environment_key = module.guacamole.environment_key_name
  guacamole_instance_id = module.guacamole.guacamole_instance_id
}

module "vpc" {
    source = "./vpc"
}

module "web_server" {
    source = "./web_server"
    vpc_id = module.vpc.vpc_id_project
    public_subnet_id = module.vpc.subnet_public_id
    zabbix_private_ip = var.zabbix_private_ip
    database_private_ip = var.database_private_ip
    guacamole_private_ip = var.guacamole_private_ip
    web_server_private_ip = var.web_server_private_ip
    environment_key = module.guacamole.environment_key_name
}

module "zabbix" {
    source = "./zabbix"
    vpc_id = module.vpc.vpc_id_project
    public_subnet_id = module.vpc.subnet_public_id
    database_private_ip = var.database_private_ip
    guacamole_private_ip = var.guacamole_private_ip
    web_server_private_ip = var.web_server_private_ip
    zabbix_private_ip = var.zabbix_private_ip
    environment_key = module.guacamole.environment_key_name
}