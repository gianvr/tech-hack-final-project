resource "aws_security_group" "security_group_zabbix" {
  name        = "security-group-zabbix"
  description = "Allow SSH from anywhere"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.guacamole_private_ip}/32"] 
  }

  ingress {
    from_port   = 10051
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20", "172.31.16.0/20"] 
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "zabbix" {
  ami                    = "ami-0e83be366243f524a"
  instance_type          = "t2.medium"             
  key_name               =  var.environment_key
  
  subnet_id              = var.public_subnet_id

  associate_public_ip_address = true 

  user_data = file("${path.module}/zabbix.sh")

  private_ip = var.zabbix_private_ip

  vpc_security_group_ids = [aws_security_group.security_group_zabbix.id]
  
  root_block_device {
    volume_type = "gp2"
    volume_size = 15
    delete_on_termination = true
  }
  
  tags = {
    Name = "zabbix"
  }
}
