#!/bin/bash

sudo apt -y remove needrestart

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::options::="--force-confold" dist-upgrade

sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mysql-server php php-pear php-cgi php-common libapache2-mod-php php-mbstring php-net-socket php-gd php-xml-util php-mysql php-bcmath -y

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

sudo mysql <<EOF
CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;
CREATE USER zabbix@localhost IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -uzabbix --password='password' zabbix

sudo mysql <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
QUIT;
EOF

sudo sed -i 's/^# DBPassword=$/DBPassword=password/' /etc/zabbix/zabbix_server.conf

sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

sudo apt install language-pack-en -y

echo -e "HostKeyAlgorithms=ssh-rsa\nPubkeyAcceptedAlgorithms=+ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd