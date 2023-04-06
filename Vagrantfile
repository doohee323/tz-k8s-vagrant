# -*- mode: ruby -*-
# vi: set ft=ruby :

IMAGE_NAME = "hashicorp/bionic64"
COUNTER = 2
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
    v.cpus = 2
  end

  config.vm.define "kube-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.provider "hyperv"
    master.enable_virtualization_extensions = true
    master.linked_clone = true
    master.vm.network "public_network", ip: "192.168.0.200"
#     master.vm.network "private_network", ip: "192.168.0.200"
#     master.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
#     master.vm.network "forwarded_port", guest: 6443, host: 6443
#     master.vm.network "forwarded_port", guest: 80, host: 8080
# #     master.vm.network "forwarded_port", guest: 443, host: 443
#     master.vm.network "forwarded_port", guest: 32449, host: 32449   # prometheus
#     master.vm.network "forwarded_port", guest: 30912, host: 30912   # grafana
#     master.vm.network "forwarded_port", guest: 31000, host: 31000   # jenkins
#     master.vm.network "forwarded_port", guest: 8081, host: 8081     # nexus
#     master.vm.network "forwarded_port", guest: 5000, host: 5000     # docker_repo
    master.vm.hostname = "kube-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/master.sh"), :args => master.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "kube-node#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.provider "hyperv"
        node.enable_virtualization_extensions = true
        node.linked_clone = true
        node.vm.network "public_network", ip: "192.168.0.#{i + 200}"
#         node.vm.network "private_network", ip: "192.168.0.#{i + 200}"
#         node.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
        node.vm.hostname = "kube-node#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
    end
  end

#     config.vm.define "kube-node1" do |node|
#         node.vm.box = IMAGE_NAME
#         node.vm.network "public_network", ip: "192.168.0.27"
#         node.vm.network "forwarded_port", guest: 22, host: "6011", auto_correct: true, id: "ssh"
#         node.vm.hostname = "kube-node1"
#         node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
#     end
#
#     config.vm.define "kube-node2" do |node|
#         node.vm.box = IMAGE_NAME
#         node.vm.network "public_network", ip: "192.168.0.30"
#         node.vm.network "forwarded_port", guest: 22, host: "6012", auto_correct: true, id: "ssh"
#         node.vm.hostname = "kube-node2"
#         node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
#     end
end

