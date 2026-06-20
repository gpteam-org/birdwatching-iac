# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Infrastructure layout (matches diagram):
#
#   Vagrant (local)
#     ├── LB        (NGINX)            192.168.56.10
#     ├── WebServer1(NGINX + Flask)     192.168.56.11
#     ├── WebServer2(NGINX + Flask)     192.168.56.12
#     └── DB        (PostgreSQL)        192.168.56.13
#
# LB load-balances traffic across WebServer1 and WebServer2.
# Each web server talks to the DB over the private network.

VAGRANTFILE_API_VERSION = "2"

BOX = "ubuntu/jammy64"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # ---------- Load Balancer ----------
  config.vm.define "lb" do |lb|
    lb.vm.box = BOX
    lb.vm.hostname = "lb"
    lb.vm.network "private_network", ip: "192.168.56.10"
    lb.vm.network "forwarded_port", guest: 80, host: 8080
    lb.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
    lb.vm.provision "shell", path: "scripts/lb.sh"
  end

  # ---------- Web Server 1 ----------
  config.vm.define "web1" do |web1|
    web1.vm.box = BOX
    web1.vm.hostname = "web1"
    web1.vm.network "private_network", ip: "192.168.56.11"
    web1.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
    web1.vm.provision "shell", path: "scripts/web.sh", args: ["WebServer 1", "192.168.56.13"]
  end

  # ---------- Web Server 2 ----------
  config.vm.define "web2" do |web2|
    web2.vm.box = BOX
    web2.vm.hostname = "web2"
    web2.vm.network "private_network", ip: "192.168.56.12"
    web2.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
    web2.vm.provision "shell", path: "scripts/web.sh", args: ["WebServer 2", "192.168.56.13"]
  end

  # ---------- Database ----------
  config.vm.define "db" do |db|
    db.vm.box = BOX
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.56.13"
    db.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
    db.vm.provision "shell", path: "scripts/db.sh"
  end

end
