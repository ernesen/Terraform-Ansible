#!/bin/sh

sudo apt-get install language-pack-en -y

sudo apt-get install -y python-software-properties debconf-utils
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo apt-add-repository "deb https://pkg.jenkins.io/debian-stable binary/"
sudo apt install jenkins -y
sudo apt-get update

sudo apt-get install apache2 -y 
sudo a2enmod proxy
sudo a2enmod proxy_http

IP_PUBLIC=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
IP_LOCAL=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

#cat > sudo /etc/apache2/sites-available/jenkins.conf <<SCRPIT
MY_JENKINS="
<VirtualHost *:80>
  ServerName $IP_PUBLIC
  ProxyRequests Off
  <Proxy *>
    Order deny,allow
    Allow from all
  </Proxy>
  ProxyPreserveHost on
  ProxyPass / http://localhost:8080/
</VirtualHost>
"

echo "${MY_JENKINS}" | sudo tee /etc/apache2/sites-available/jenkins.conf 

sudo a2ensite jenkins
sudo systemctl restart apache2

