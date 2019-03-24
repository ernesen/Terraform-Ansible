#!/bin/sh

# add addresses to /etc/hosts 
echo "192.168.99.160 terraform.sample.com" | sudo tee -a /etc/hosts 

TERRAFORM_VERSION="0.11.11"
WORKDIR=/tmp/terraform
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Install Terraform 
curl -f "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/
sudo chmod +x  /usr/local/bin/terraform

# https://github.com/adammck/terraform-inventory
# Install terraform-inventory 
wget https://github.com/adammck/terraform-inventory/releases/download/v0.8/terraform-inventory_v0.8_linux_amd64.zip
sudo unzip terraform-inventory_v0.8_linux_amd64.zip -d /usr/local/bin/
sudo chmod +x  /usr/local/bin/terraform-inventory

# https://www.cyberciti.biz/faq/how-to-set-up-ssh-keys-on-linux-unix/
#ssh-keygen -t rsa -b 4096 -f ~/.ssh/vps-cloud.web-server.key -C "My web-server key"
cd ~
rm -rf "$WORKDIR"


