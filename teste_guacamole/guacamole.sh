#!/bin/bash

sudo apt -y remove needrestart

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::options::="--force-confold" dist-upgrade

sudo iptables -A POSTROUTING -t nat -s 172.31.16.0/20 -j MASQUERADE
sudo bash -c 'echo "1" > /proc/sys/net/ipv4/ip_forward'
sudo sysctl -w net.ipv4.ip_forward=1

sudo apt update && sudo apt upgrade -y

echo | sudo add-apt-repository ppa:remmina-ppa-team/remmina-next
sudo apt-get update
sudo apt-get install -y freerdp2-dev freerdp2-x11

wget -O guac-install.sh https://git.io/fxZq5
chmod +x guac-install.sh
sudo ./guac-install.sh --mysqlpwd password --guacpwd password --nomfa --installmysql

wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-auth-totp-1.5.3.tar.gz
tar -xzvf guacamole-auth-totp-1.5.3.tar.gz
cd guacamole-auth-totp-1.5.3/
sudo cp guacamole-auth-totp-1.5.3.jar /etc/guacamole/extensions

sudo systemctl restart tomcat9

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent -y