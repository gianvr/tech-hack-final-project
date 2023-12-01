
resource "aws_security_group" "security_group_web_server" {
  name        = "testing-security-group-web-server"
  description = "Allow SSH from anywhere"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.guacamole_private_ip}/32"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
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

data "template_file" "web_server" {
  template = file("${path.module}/web_server.sh")
}


resource "aws_instance" "web_server" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.medium"             
  key_name               =  var.environment_key
  
  subnet_id              = var.public_subnet_id

  associate_public_ip_address = true 

  iam_instance_profile = var.ec2_iam_instance_profile

  private_ip = var.web_server_private_ip

  user_data = <<-EOF
  ${data.template_file.web_server.rendered}
  sudo -u www-data sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '${var.database_private_ip}' );/" /srv/www/wordpress/wp-config.php
  sudo sed -i "s/Server=127.0.0.1/Server=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
  sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
  sudo sed -i "s/Hostname=Zabbix server/Hostname=web_server/" /etc/zabbix/zabbix_agentd.conf

  sudo systemctl restart zabbix-agent
  EOF

  vpc_security_group_ids = [aws_security_group.security_group_web_server.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = 15
    delete_on_termination = true
  }
  tags = {
    Name = "testing-web-server"
  }
}
