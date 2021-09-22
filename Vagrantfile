# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrant setup uses libvirt instead of virtualbox.
# Please edit the section of config.vm.provider to use your favourite
# virtualization poison.

# Usage - $ CUSTOM_IP="192.168.33.123" vagrant up
# By providing custom IP address you give your VM a static address
# which makes life easier

Vagrant.configure("2") do |config|
  ip_address = ENV['CUSTOM_IP']
  vagrant_root = File.dirname(__FILE__)

  config.vm.box = "generic/ubuntu2004"
  config.vm.boot_timeout = 600
  config.vm.network "private_network", ip: ip_address

  # add current project root under ~/src on the machine
  config.vm.synced_folder vagrant_root, "/home/vagrant/src", type: "nfs"

  # edit this section to use your favourite virtualization software like virtualbox
  config.vm.provider :libvirt do |libvirt, override|
    libvirt.memory = 2048
    libvirt.nested = true
  end

  config.vm.provision "shell", inline: <<-SHELL
    eval `ssh-agent -s`
    sudo apt update
    sudo apt upgrade -y

    sudo apt install -y apt-transport-https ca-certificates  gnupg-agent  software-properties-common  build-essential
    sudo apt install -y lua5.3  luarocks  curl  libreadline-dev  luajit
    sudo apt install libpcre3 libpcre3-dev

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo groupadd docker
    sudo usermod -aG docker $(whoami)
    sudo service docker restart

    sudo apt install -y docker-compose

    sudo apt install jq -y

  SHELL
end
