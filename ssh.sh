cat << 'EOF' > ~/.ssh/config
Host web1 192.168.56.101
    HostName 192.168.56.101
    User vagrant
    IdentityFile "D:/vagrant_project/.vagrant/machines/web1/virtualbox/private_key"
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
Host web2 192.168.56.102
    HostName 192.168.56.102
    User vagrant
    IdentityFile "D:/vagrant_project/.vagrant/machines/web2/virtualbox/private_key"
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
Host nginx 192.168.56.103
    HostName 192.168.56.103
    User vagrant
    IdentityFile "D:/vagrant_project/.vagrant/machines/nginx/virtualbox/private_key"
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
Host db 192.168.56.104
    HostName 192.168.56.104
    User vagrant
    IdentityFile "D:/vagrant_project/.vagrant/machines/db/virtualbox/private_key"
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

chmod 600 ~/.ssh/config