# -*- mode: ruby -*-
# vi: set ft=ruby :

# sudo vi /etc/vbox/networks.conf
#       * 10.0.0.0/8 192.168.1.0/24 192.168.0.0/16
#       * 2001::/64

IMAGE_NAME = "bento/ubuntu-20.04"
COUNTER = 2
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.define "kube-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "private_network", ip: "192.168.1.10"
    #master.vm.network "public_network"
    master.vm.network "forwarded_port", guest: 22, host: 60100, auto_correct: true, id: "ssh"
    master.vm.network "forwarded_port", guest: 6443, host: 6443
    master.vm.network "forwarded_port", guest: 80, host: 8080
    master.vm.network "forwarded_port", guest: 8001, host: 8001
#     master.vm.network "forwarded_port", guest: 443, host: 443
    master.vm.network "forwarded_port", guest: 32699, host: 32699   # dashboard
    master.vm.network "forwarded_port", guest: 32698, host: 32698   # forwarding test
    master.vm.network "forwarded_port", guest: 32449, host: 32449   # prometheus
    master.vm.network "forwarded_port", guest: 30912, host: 30912   # grafana
    master.vm.network "forwarded_port", guest: 31000, host: 31000   # jenkins
    master.vm.network "forwarded_port", guest: 8081, host: 8081     # nexus
    master.vm.network "forwarded_port", guest: 5050, host: 5050     # docker_repo
    master.vm.network "forwarded_port", guest: 30007, host: 30007   # app
    master.vm.hostname = "kube-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/master.sh"), :args => master.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "kube-node-#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.network "private_network", ip: "192.168.1.#{i + 10}"
        node.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
        node.vm.hostname = "kube-node-#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
    end
  end
end

