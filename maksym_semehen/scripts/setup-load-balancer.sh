#!/bin/bash

sudo apt update
sudo apt-get install -y nginx libnginx-mod-http-modsecurity git wget

# setup load balancer
sudo rm -f /etc/nginx/sites-enabled/default

sudo bash -c 'cat > /etc/nginx/conf.d/load-balancer.conf <<EOF
upstream web-servers {
    server 192.168.56.102;
    server 192.168.56.103;
}

server {
    listen 80;

    location / {
        proxy_pass http://web-servers;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF'

# setup modsecurity
sudo mkdir -p /etc/nginx/modsec
sudo wget -O /etc/nginx/modsec/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
sudo wget -O /etc/nginx/modsec/unicode.mapping https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/unicode.mapping

# enable waf mode
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf

# install crs
cd /etc/nginx/modsec
sudo git clone --depth 1 https://github.com/coreruleset/coreruleset.git owasp-crs
sudo cp owasp-crs/crs-setup.conf.example owasp-crs/crs-setup.conf

# combine modsecurity and crs into one main rules file
cat <<EOF | sudo tee /etc/nginx/modsec/main.conf
Include /etc/nginx/modsec/modsecurity.conf
Include /etc/nginx/modsec/owasp-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-crs/rules/*.conf
EOF

# turn on modsecurity for all incoming requests
sudo bash -c 'cat > /etc/nginx/conf.d/modsecurity.conf <<EOF
modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/main.conf;
EOF'

sudo systemctl restart nginx
