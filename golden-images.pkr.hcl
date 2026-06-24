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
  skip_add     = true # assumes that you already installed debian/bookworm64 if not will cause error
}

build {
  # build web server image
  source "source.vagrant.golden-images" {
    name       = "web-server"
    output_dir = "images/web-server"
  }

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y python3 python3-pip python3-venv git nginx gunicorn ufw"
    ]
  }

  # build load balancer image
  source "source.vagrant.golden-images" {
    name       = "load-balancer"
    output_dir = "images/load-balancer"
  }

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx libnginx-mod-http-modsecurity git wget ufw"
    ]
  }

  # build database image
  source "source.vagrant.golden-images" {
    name       = "database"
    output_dir = "images/database"
  }

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y postgresql openssl ufw"
    ]
  }
}
