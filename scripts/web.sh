#!/usr/bin/env bash
set -euo pipefail

SERVER_NAME="${1:-WebServer}"
DB_IP="${2:-192.168.56.13}"

apt-get update -y
apt-get install -y nginx python3 python3-venv python3-pip

mkdir -p /opt/app
cat >/opt/app/app.py <<EOF
from flask import Flask, jsonify
import socket

app = Flask(__name__)

SERVER_NAME = "${SERVER_NAME}"
DB_IP = "${DB_IP}"

@app.route("/")
def index():
    return jsonify(
        message=f"Hello from {SERVER_NAME}",
        hostname=socket.gethostname(),
        db_backend=DB_IP,
    )

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

python3 -m venv /opt/app/venv
/opt/app/venv/bin/pip install --quiet flask gunicorn

cat >/etc/systemd/system/flaskapp.service <<EOF
[Unit]
Description=Flask app for ${SERVER_NAME}
After=network.target

[Service]
WorkingDirectory=/opt/app
ExecStart=/opt/app/venv/bin/gunicorn -w 2 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flaskapp
systemctl restart flaskapp

cat >/etc/nginx/sites-available/web.conf <<EOF
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
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/web.conf /etc/nginx/sites-enabled/web.conf

nginx -t
systemctl enable nginx
systemctl restart nginx
