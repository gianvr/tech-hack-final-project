resource "tls_private_key" "environment_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "environment-key-pair" {
    content = tls_private_key.environment_key.private_key_pem
    filename = "environment-key-pair.pem"
}


resource "aws_key_pair" "environment_key_pair" {
  key_name   = "environment-key-pair"
  public_key =  tls_private_key.environment_key.public_key_openssh
}


resource "aws_security_group" "security_group_guacamole" {
  name        = "security-group-guacamole"
  description = "Allow SSH from anywhere"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.database_private_ip}/32"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.database_private_ip}/32"] 
  }

  ingress {
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = ["${var.zabbix_private_ip}/32"] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

data "template_file" "guacamole" {
  template = file("${path.module}/guacamole.sh")
}

resource "aws_instance" "guacamole" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.medium"             
  key_name               =  aws_key_pair.environment_key_pair.key_name
  
  subnet_id              = var.public_subnet_id

  private_ip = var.guacamole_private_ip

  associate_public_ip_address = true 

  source_dest_check = false

  user_data = <<-EOF
    ${data.template_file.guacamole.rendered}

    sudo sed -i "s/Server=127.0.0.1/Server=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
    sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
    sudo sed -i "s/Hostname=Zabbix server/Hostname=guacamole/" /etc/zabbix/zabbix_agentd.conf
    sudo systemctl restart zabbix-agent

    mysql -h localhost -u guacamole_user -p'password' <<EOF
    USE guacamole_db;
    INSERT INTO guacamole_connection (connection_id, connection_name, protocol)
    VALUES (1, 'Web_server', 'ssh');
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
      (1, 'username', 'ubuntu'),
      (1, 'hostname', '${var.web_server_private_ip}'),
      (1, 'private-key', '${tls_private_key.environment_key.private_key_pem}');
    
    INSERT INTO guacamole_connection (connection_id, connection_name, protocol)
    VALUES (2, 'Zabbix', 'ssh');
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
      (2, 'username', 'ubuntu'),
      (2, 'hostname', '${var.zabbix_private_ip}'),
      (2, 'private-key', '${tls_private_key.environment_key.private_key_pem}');
    
    INSERT INTO guacamole_connection (connection_id, connection_name, protocol)
    VALUES (3, 'Database', 'ssh');
    INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
    VALUES
      (3, 'username', 'ubuntu'),
      (3, 'hostname', '${var.database_private_ip}'),
      (3, 'private-key', '${tls_private_key.environment_key.private_key_pem}');
    EOF

  vpc_security_group_ids = [aws_security_group.security_group_guacamole.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = 15
    delete_on_termination = true
  }
  tags = {
    Name = "guacamole"
  }
}


