#!/bin/bash

sudo apt -y remove needrestart

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::options::="--force-confold" dist-upgrade

sudo apt update && sudo apt upgrade -y


sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip \
                 ruby-full

sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo "<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-available/wordpress.conf

sudo a2ensite wordpress

sudo a2enmod rewrite

sudo a2dissite 000-default

sudo service apache2 reload

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/password/' /srv/www/wordpress/wp-config.php

keys="keys.py"

keys_code=$(cat <<EOL
import requests

url = "https://api.wordpress.org/secret-key/1.1/salt/"

path = "/srv/www/wordpress/wp-config.php"

linha_sub = "define( 'AUTH_KEY',         'put your unique phrase here' );"

response = requests.get(url)

print("Changing keys in wp-config.php...")

if response.status_code == 200:
    
    conteudo = str(response.text)

    with open(path, 'r') as arquivo:
        linhas = arquivo.readlines()

    indice = next((i for i, linha in enumerate(linhas) if linha_sub in linha), None)

    if indice is not None:
        del linhas[indice:indice + 8]

    if indice is not None:
        linhas[indice] = conteudo + '\n'

    with open(path, 'w') as arquivo:
        arquivo.writelines(linhas)
    
    print("Keys in wp-config.php successfully changed")

else:
    print(f"Error getting values from site. Status code: {response.status_code}")
EOL
)

echo "$keys_code" > "$keys"

chmod +x "$keys"

sudo python3 keys.py

echo -e "HostKeyAlgorithms=ssh-rsa\nPubkeyAcceptedAlgorithms=+ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent -y
