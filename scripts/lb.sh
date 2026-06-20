#!/usr/bin/env bash
set -euo pipefail

apt-get update -y
apt-get install -y nginx

WEB1_IP="192.168.56.11"
WEB2_IP="192.168.56.12"

cat >/etc/nginx/sites-available/lb.conf <<EOF
upstream backend {
    server ${WEB1_IP}:80;
    server ${WEB2_IP}:80;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/lb.conf /etc/nginx/sites-enabled/lb.conf

nginx -t
systemctl enable nginx
systemctl restart nginx
