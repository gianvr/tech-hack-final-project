resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = var.guacamole_network_interface_id
  }

  tags = {
    Name = "testing_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "testing_private_subnet"
  }
}

resource "aws_security_group" "security_group_database" {
  name        = "testing_security-group-database"
  description = "Allow SSH from anywhere"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.guacamole_private_ip}/32"] 
  }

  ingress {
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = ["${var.zabbix_private_ip}/32"] 
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.web_server_private_ip}/32"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "database" {
  template = file("${path.module}/database.sh")
}

resource "aws_instance" "database" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.medium"             
  key_name               =  var.environment_key
  
  subnet_id              =  aws_subnet.private_subnet.id

  associate_public_ip_address = false

  user_data = <<-EOF
  ${data.template_file.database.rendered}
  sudo sed -i "s/Server=127.0.0.1/Server=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
  sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=${var.zabbix_private_ip}/" /etc/zabbix/zabbix_agentd.conf
  sudo sed -i "s/Hostname=Zabbix server/Hostname=database/" /etc/zabbix/zabbix_agentd.conf

  sudo systemctl restart zabbix-agent
  EOF

  private_ip = var.database_private_ip

  root_block_device {
    volume_type = "gp2"
    volume_size = 15
    delete_on_termination = true
  }

  depends_on = [var.guacamole_instance_id]

  vpc_security_group_ids = [aws_security_group.security_group_database.id]
  
  
  tags = {
    Name = "testing-database"
  }
}
