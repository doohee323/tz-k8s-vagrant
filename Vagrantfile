# -*- mode: ruby -*-
# vi: set ft=ruby :

IMAGE_NAME = "bento/ubuntu-20.04"
COUNTER = 2
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.define "kube-slave" do |slave|
    slave.vm.box = IMAGE_NAME
    slave.vm.network "private_network", ip: "192.168.1.15"
    #slave.vm.network "public_network"
    slave.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
    slave.vm.network "forwarded_port", guest: 6443, host: 6443
    slave.vm.network "forwarded_port", guest: 80, host: 8080
    slave.vm.network "forwarded_port", guest: 8001, host: 8001
#     slave.vm.network "forwarded_port", guest: 443, host: 443
    slave.vm.network "forwarded_port", guest: 32699, host: 32699   # dashboard
    slave.vm.network "forwarded_port", guest: 32698, host: 32698   # forwarding test
    slave.vm.network "forwarded_port", guest: 32449, host: 32449   # prometheus
    slave.vm.network "forwarded_port", guest: 30912, host: 30912   # grafana
    slave.vm.network "forwarded_port", guest: 31000, host: 31000   # jenkins
    slave.vm.network "forwarded_port", guest: 8081, host: 8081     # nexus
    slave.vm.network "forwarded_port", guest: 5050, host: 5050     # docker_repo
    slave.vm.network "forwarded_port", guest: 30007, host: 30007   # app
    slave.vm.hostname = "kube-slave"
    slave.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => slave.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "kube-slave-#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.network "private_network", ip: "192.168.1.#{i + 15}"
        node.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
        node.vm.hostname = "kube-slave-#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
    end
  end
end

