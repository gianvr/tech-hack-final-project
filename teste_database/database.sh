#!/bin/bash

sudo apt -y remove needrestart

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::options::="--force-confold" dist-upgrade

echo -e "HostKeyAlgorithms=ssh-rsa\nPubkeyAcceptedAlgorithms=+ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo apt update && sudo apt upgrade -y

sudo apt install mariadb-server -y

sudo mariadb <<EOF
CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'wordpress'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
FLUSH PRIVILEGES; 
EOF

sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

sudo service mariadb start

sudo systemctl restart mariadb

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent -y