Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.ssh.extra_args = ["-o", "PubkeyAcceptedKeyTypes=+ssh-rsa", "-o", "HostKeyAlgorithms=+ssh-rsa"]

  config.vm.define "web1" do |web1|
    web1.vm.network "private_network", ip: "192.168.56.101"
    web1.vm.hostname = "web1"
    web1.vm.synced_folder "../bird_watching_app", "/vagrant", disabled: false
    web1.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
    end

    web1.vm.provision "shell", path: "web1.sh"
  end

  config.vm.define "web2" do |web2|
    web2.vm.network "private_network", ip: "192.168.56.102"
    web2.vm.hostname = "web2"
    web2.vm.synced_folder "../bird_watching_app", "/vagrant", disabled: false
    web2.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
    end

    web2.vm.provision "shell", path: "web2.sh"
  end

  config.vm.define "nginx" do |nginx|
    nginx.vm.network "private_network", ip: "192.168.56.103"
    nginx.vm.network "forwarded_port", guest: 80, host: 8080
    nginx.vm.hostname = "nginx"
    nginx.vm.synced_folder "../bird_watching_app", "/vagrant", disabled: false
    nginx.vm.provider "virtualbox" do |vb|
       vb.memory = "512"
    end

    nginx.vm.provision "shell", path: "nginx.sh"
  end

  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.56.104"
    db.vm.hostname = "db"
    db.vm.synced_folder "../bird_watching_app", "/vagrant", disabled: false
    db.vm.provider "virtualbox" do |vb|
       vb.memory = "512"
    end

    db.vm.provision "shell", path: "db.sh"
  end


end