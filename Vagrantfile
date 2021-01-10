# -*- mode: ruby -*-
# vi: set ft=ruby :

# default_network_interface=`ip addr show | awk '/inet.*brd/{print $NF}'`.split(/\n+/)
default_network_interface=`ifconfig | awk '/UP/ && !/LOOPBACK/ && !/POINTOPOINT/' | awk '{print substr($1, 1, length($1)-1)}'`.split(/\n+/)

IMAGE_NAME = "bento/ubuntu-18.04"
COUNTER = 2
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.define "k8s-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "public_network", bridge: default_network_interface
    master.vm.hostname = "k8s-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/master.sh"), :args => master.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "node-#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.network "public_network", bridge: default_network_interface
        node.vm.hostname = "node-#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
    end
  end
end

