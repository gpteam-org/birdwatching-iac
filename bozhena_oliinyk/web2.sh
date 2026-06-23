apt-get update
apt-get install -y nginx python3-pip python3-venv python3-flask

rm -rf /var/www/bird_watching_app
git clone -b GPT-46-Initial-project-infrastructure https://github.com/gpteam-org/birdwatching-app.git /var/www/bird_watching_app
cd /var/www/bird_watching_app/bozhena_oliinyk/web2
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install gunicorn flask


sudo tee /etc/systemd/system/bird_watching_app.service > /dev/null <<EOF
[Unit]
Description=Gunicorn Birdwatching
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/bird_watching_app/bozhena_oliinyk/web2
ExecStart=/var/www/bird_watching_app/bozhena_oliinyk/web2/.venv/bin/gunicorn -w 3 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bird_watching_app
sudo systemctl start bird_watching_app

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