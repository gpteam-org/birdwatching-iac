packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

# use debian/bookworm64 as base image
source "vagrant" "golden-images" {
  communicator = "ssh"
  source_path  = "debian/bookworm64"
  provider     = "virtualbox"
}

build {
  # web server image
  source "source.vagrant.golden-images" {
    name = "web-server"
  }

  provisioner "shell" {
    only   = ["vagrant.web-server"]
    inline = ["sudo apt update && sudo apt install -y python3 python3-pip python3-venv git nginx gunicorn ufw"]
  }
  
  # load balancer image
  source "source.vagrant.golden-images" {
    name = "load-balancer"
  }

  provisioner "shell" {
    only   = ["vagrant.load-balancer"]
    inline = ["sudo apt update && sudo apt install -y nginx libnginx-mod-http-modsecurity git wget ufw"]
  }

  # build database image
  source "source.vagrant.golden-images" {
    name = "database"
  }

  provisioner "shell" {
    only   = ["vagrant.database"]
    inline = ["sudo apt update && sudo apt install -y postgresql openssl ufw"]
  }

  # store all images
  post-processor "vagrant" {
    output = "images/{{.BuildName}}-image.box"
  }
}
