apt-get update
apt-get install -y nginx python3-pip python3-flask sshpass
mkdir -p /var/www/templates
cp /vagrant/web1/web1.html /var/www/templates/index.html
cp /vagrant/web1/app.py /var/www/app.py

cd /var/www
nohup python3 app.py > /dev/null 2>&1 &

cat <<EOT > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT

systemctl restart nginx