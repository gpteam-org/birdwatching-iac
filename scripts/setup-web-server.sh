#!/bin/bash

# add firewall
sudo ufw allow 22/tcp # SSH
sudo ufw allow 80/tcp # Nginx HTTP
sudo ufw --force enable

# clone birdwatching-app
git clone https://github.com/gpteam-org/birdwatching-app.git /var/www/birdwatching-app

# install dependencies
cd /var/www/birdwatching-app
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# AI assisted section
# --- --- ---

# systemd service for Gunicorn
sudo tee /etc/systemd/system/birdwatching-app.service > /dev/null <<EOF
[Unit]
Description=Gunicorn Birdwatching
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/birdwatching-app
ExecStart=/var/www/birdwatching-app/venv/bin/gunicorn -w 3 -b 127.0.0.1:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable birdwatching-app
sudo systemctl start birdwatching-app

# --- --- ---

# nginx reverse proxy
sudo tee /etc/nginx/sites-available/birdwatching-app > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo rm /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/birdwatching-app /etc/nginx/sites-enabled/
sudo systemctl restart nginx
