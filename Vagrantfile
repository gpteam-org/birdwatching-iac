servers=[
  {
    :hostname => "database",
    :ip => "192.168.56.101",
    :box => "debian/bookworm64",
    :script => "scripts/setup-database.sh",
    :memory => 4096,
    :cpus => 2
  },
  {
    :hostname => "web-server-1",
    :ip => "192.168.56.102",
    :box => "debian/bookworm64",
    :script => "scripts/setup-web-server.sh",
    :memory => 2048,
    :cpus => 2
  },
  {
    :hostname => "web-server-2",
    :ip => "192.168.56.103",
    :box => "debian/bookworm64",
    :script => "scripts/setup-web-server.sh",
    :memory => 2048,
    :cpus => 2
  },
  {
    :hostname => "load-balancer",
    :ip => "192.168.56.104",
    :box => "debian/bookworm64",
    :script => "scripts/setup-load-balancer.sh",
    :memory => 1024,
    :cpus => 1
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.provider "virtualbox" do |vb|
        vb.memory = machine[:memory]
        vb.cpus = machine[:cpus]
      end
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "shell", path: machine[:script]
    end
  end
end
