# -*- mode: ruby -*-
# vi: set ft=ruby :

IMAGE_NAME = "bento/ubuntu-20.04"
COUNTER = 2
Vagrant.configure("2") do |config|
  config.vm.box = IMAGE_NAME
  config.ssh.insert_key=false
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.define "kube-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "private_network", ip: "192.168.0.127"
    master.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
    master.vm.hostname = "kube-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/master.sh"), :args => master.vm.hostname
  end

end

