# -*- mode: ruby -*-
# vi: set ft=ruby :

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
    master.vm.network "private_network", ip: "192.168.1.10"
    #master.vm.network "public_network"
    master.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
    master.vm.network "forwarded_port", guest: 6443, host: 6443
    master.vm.network "forwarded_port", guest: 80, host: 80
    master.vm.network "forwarded_port", guest: 443, host: 443
    master.vm.network "forwarded_port", guest: 8001, host: 8001
    master.vm.network "forwarded_port", guest: 32699, host: 32699   # dashboard
    master.vm.network "forwarded_port", guest: 32698, host: 32698   # forwarding test
    master.vm.network "forwarded_port", guest: 32449, host: 32449   # prometheus
    master.vm.network "forwarded_port", guest: 30912, host: 30912   # grafana
    master.vm.network "forwarded_port", guest: 31000, host: 31000   # jenkins
    master.vm.network "forwarded_port", guest: 30007, host: 30007   # app (tz-py-crawler)
    master.vm.network "forwarded_port", guest: 8081, host: 8081     # nexus
    master.vm.network "forwarded_port", guest: 5000, host: 5000     # docker_repo
    master.vm.network "forwarded_port", guest: 32181, host: 32181   # zookeeper
    master.vm.network "forwarded_port", guest: 30092, host: 30092   # kafka
    master.vm.network "forwarded_port", guest: 30432, host: 30432   # postgresql
    master.vm.network "forwarded_port", guest: 32632, host: 32632   # wordpress
    master.vm.network "forwarded_port", guest: 30085, host: 30085   # wordpress
    master.vm.network "forwarded_port", guest: 8500, host: 8500     # consul-server
    master.vm.network "forwarded_port", guest: 31699, host: 31699   # consul-ui
    master.vm.network "forwarded_port", guest: 31092, host: 31092   # consul-test
    master.vm.network "forwarded_port", guest: 8200, host: 8200     # vault
    master.vm.network "forwarded_port", guest: 31700, host: 31700   # vault-ui
    master.vm.network "forwarded_port", guest: 31701, host: 31701     # openldap
    master.vm.network "forwarded_port", guest: 32520, host: 32520     # openldap2

    master.vm.network "forwarded_port", guest: 30500, host: 30500     # tgd-web
    master.vm.network "forwarded_port", guest: 30800, host: 30800     # tgd-nginx

    master.vm.hostname = "k8s-master"
    master.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/master.sh"), :args => master.vm.hostname
  end

  (1..COUNTER).each do |i|
    config.vm.define "node-#{i}" do |node|
        node.vm.box = IMAGE_NAME
        node.vm.network "private_network", ip: "192.168.1.#{i + 11}"
        node.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
        node.vm.hostname = "node-#{i}"
        node.vm.provision "shell", :path => File.join(File.dirname(__FILE__),"scripts/local/node.sh"), :args => node.vm.hostname
    end
  end
end

