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
    ec2_iam_instance_profile = module.role_ec2.iam_profile
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

module "cicd" {
    source = "./cicd"
    application_name = module.web_server.instance_name
    codedeploy_arn = module.role_codedeploy.codedeploy_arn
    cicd_arn = module.role_pipeline.pipeline_arn

    //Testing Enviroment application
    testing_application_name = module.testing_web_server.instance_name
}

module "role_ec2" {
    source = "./role_ec2"
}

module "role_codedeploy" {
    source = "./role_codedeploy"
}

module "role_pipeline" {
    source = "./role_pipeline"
}

// Testing Enviroment Modules

module "testing_guacamole" {
  source = "./teste_guacamole"
  vpc_id = module.testing_vpc.vpc_id_project
  public_subnet_id = module.testing_vpc.subnet_public_id
  database_private_ip = var.testing_database_private_ip
  web_server_private_ip = var.testing_web_server_private_ip
  zabbix_private_ip = var.testing_zabbix_private_ip
  guacamole_private_ip = var.testing_guacamole_private_ip
}

module "testing_database" {
  source = "./teste_database"
  guacamole_network_interface_id = module.testing_guacamole.guacamole_network_interface_id
  vpc_id = module.testing_vpc.vpc_id_project
  zabbix_private_ip = var.testing_zabbix_private_ip
  guacamole_private_ip = var.testing_guacamole_private_ip
  web_server_private_ip = var.testing_web_server_private_ip
  database_private_ip = var.testing_database_private_ip
  environment_key = module.testing_guacamole.environment_key_name
  guacamole_instance_id = module.testing_guacamole.guacamole_instance_id
}

module "testing_vpc" {
    source = "./teste_vpc"
}

module "testing_web_server" {
    source = "./teste_web_server"
    vpc_id = module.testing_vpc.vpc_id_project
    public_subnet_id = module.testing_vpc.subnet_public_id
    zabbix_private_ip = var.testing_zabbix_private_ip
    database_private_ip = var.testing_database_private_ip
    guacamole_private_ip = var.testing_guacamole_private_ip
    web_server_private_ip = var.testing_web_server_private_ip
    environment_key = module.testing_guacamole.environment_key_name
    ec2_iam_instance_profile = module.role_ec2.iam_profile
}

module "testing_zabbix" {
    source = "./teste_zabbix"
    vpc_id = module.testing_vpc.vpc_id_project
    public_subnet_id = module.testing_vpc.subnet_public_id
    database_private_ip = var.testing_database_private_ip
    guacamole_private_ip = var.testing_guacamole_private_ip
    web_server_private_ip = var.testing_web_server_private_ip
    zabbix_private_ip = var.testing_zabbix_private_ip
    environment_key = module.testing_guacamole.environment_key_name
}