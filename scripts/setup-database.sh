#!/bin/bash

sudo apt update
sudo apt install -y postgresql openssl

# add firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'
sudo ufw --force enable

sudo systemctl enable postgresql
sudo systemctl start postgresql

# generate password inside VM
DB_PASSWORD=$(openssl rand -base64 24)

# store password
echo "$DB_PASSWORD" | sudo tee /root/main_database_password.txt > /dev/null
sudo chmod 600 /root/main_database_password.txt

# create database and user
sudo -u postgres psql <<EOF
CREATE DATABASE main_database;
CREATE USER developer WITH ENCRYPTED PASSWORD '${DB_PASSWORD}';
GRANT CONNECT ON DATABASE main_database TO developer;
EOF

# allow remote listening
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

# allow requests only from web-server-1 and web-server-2
sudo bash -c 'cat >> /etc/postgresql/*/main/pg_hba.conf <<EOF
host main_database developer 192.168.56.102/32 scram-sha-256
host main_database developer 192.168.56.103/32 scram-sha-256
host main_database developer 0.0.0.0/0 reject
EOF'

sudo systemctl restart postgresql
