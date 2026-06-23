apt-get update
apt-get install -y nginx libmodsecurity3 modsecurity-crs libnginx-mod-http-modsecurity git wget

mkdir -p /etc/nginx/modsec
wget -O /etc/nginx/modsec/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
wget -O /etc/nginx/modsec/unicode.mapping https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/unicode.mapping

sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf

cd /etc/nginx/modsec
git clone --depth 1 https://github.com/coreruleset/coreruleset.git owasp-crs
cp owasp-crs/crs-setup.conf.example owasp-crs/crs-setup.conf

cat <<EOF > /etc/nginx/modsec/main.conf
Include /etc/nginx/modsec/modsecurity.conf
Include /etc/nginx/modsec/owasp-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-crs/rules/*.conf
EOF

cat <<EOT > /etc/nginx/sites-available/default
upstream backend {
    server 192.168.56.101:80;
    server 192.168.56.102:80;
}
server {
    listen 80;
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

nginx -t
systemctl restart nginx