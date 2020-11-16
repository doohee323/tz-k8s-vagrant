# -*- mode: ruby -*-
# vi: set ft=ruby :

IMAGE_NAME = "bento/ubuntu-18.04"
N = 1

Vagrant.require_version ">= 1.7.0"

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
    end

    config.vm.provision "shell", privileged: true, inline: <<-SCRIPT
        sudo apt-get update
        sudo apt install software-properties-common
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt install ansible -y
    SCRIPT

    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: "192.168.50.10"
        #master.vm.network "public_network"
        master.vm.network "forwarded_port", guest: 6443, host: 6443
        master.vm.network "forwarded_port", guest: 80, host: 8080
        master.vm.network "forwarded_port", guest: 443, host: 8080
        master.vm.hostname = "k8s-master"
        master.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode = "auto"
            ansible.playbook = "scripts/ansible/master-playbook.yml"
            ansible.extra_vars = {
                node_ip: "192.168.50.10",
            }
        end
    end

    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "192.168.50.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provision "ansible" do |ansible|
                ansible.compatibility_mode = "auto"
                ansible.playbook = "scripts/ansible/node-playbook.yml"
                ansible.extra_vars = {
                    node_ip: "192.168.50.#{i + 10}",
                }
            end
        end
    end
end