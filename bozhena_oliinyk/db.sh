apt-get update
apt-get install -y postgresql sshpass

sudo systemctl enable postgresql
sudo systemctl start postgresql

DB_PASSWORD=$(openssl rand -base64 24)

echo "$DB_PASSWORD" | sudo tee /root/main_database_password.txt > /dev/null
sudo chmod 600 /root/main_database_password.txt

sudo -u postgres psql <<EOF
CREATE DATABASE my_db;
CREATE USER dev WITH ENCRYPTED PASSWORD '${DB_PASSWORD}';
GRANT CONNECT ON DATABASE my_db TO dev;
EOF