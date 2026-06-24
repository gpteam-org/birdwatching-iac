#!/bin/bash

sudo apt update
sudo apt install -y postgresql openssl ufw

# add firewall
sudo ufw allow 22/tcp # SSH
sudo ufw allow 5432/tcp # PostgreSQL
sudo ufw --force enable

sudo systemctl enable postgresql
sudo systemctl start postgresql

# generate password inside VM
DB_PASSWORD=$(openssl rand -base64 24)

# store password
echo "$DB_PASSWORD" | sudo tee /root/birds_db_password.txt > /dev/null
sudo chmod 600 /root/birds_db_password.txt

# create database and user
sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS birds_db;
CREATE DATABASE birds_db;
DROP USER IF EXISTS developer;
CREATE USER developer WITH ENCRYPTED PASSWORD '${DB_PASSWORD}';
GRANT CONNECT ON DATABASE birds_db TO developer;
CREATE TABLE Users (
  id INT PRIMARY KEY,
  login VARCHAR(100),
  password VARCHAR(100)
);
CREATE TABLE Posts (
  id INT PRIMARY KEY,
  photo VARCHAR(100),
  description VARCHAR(100),
  location VARCHAR(100),
  user_id INT,
  FOREIGN KEY (user_id) REFERENCES Users(id)
);
CREATE TABLE Likes (
  user_id INT,
  post_id INT,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES Users(id),
  FOREIGN KEY (post_id) REFERENCES Posts(id)
);
EOF

# allow remote listening
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

# allow requests only from web-server-1 and web-server-2
sudo bash -c 'cat >> /etc/postgresql/*/main/pg_hba.conf <<EOF
host birds_db developer 192.168.56.102/32 scram-sha-256
host birds_db developer 192.168.56.103/32 scram-sha-256
host birds_db developer 0.0.0.0/0 reject
EOF'

sudo systemctl restart postgresql
