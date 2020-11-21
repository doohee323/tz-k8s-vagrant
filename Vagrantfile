# -*- mode: ruby -*-
# vi: set ft=ruby :

IMAGE_NAME = "bento/ubuntu-18.04"
COUNTER = 1
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.define "k8s-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "private_network", ip: "192.168.1.10"
    master.vm.network "forwarded_port", guest: 6443, host: 6443
    master.vm.network "forwarded_port", guest: 80, host: 8080
    master.vm.network "forwarded_port", guest: 443, host: 8080
    master.vm.network "forwarded_port", guest: 30080, host: 30080
    master.vm.hostname = "k8s-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/shells/master.sh"), :args => master.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "node-#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.network "private_network", ip: "192.168.1.#{i + 11}"
        node.vm.hostname = "node-#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/shells/node.sh"), :args => node.vm.hostname
    end
  end
end

