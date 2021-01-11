#!/usr/bin/env bash

#set -x

##################################################################
# k8s base
##################################################################

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt-get install -y docker.io apt-transport-https curl
sudo systemctl start docker
sudo systemctl enable docker
sudo apt-get update
sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm
sudo mkdir -p /root/.ssh

sudo groupadd ubuntu
sudo useradd -g ubuntu -d /home/ubuntu -s /bin/bash -m ubuntu
sudo echo "ubuntu:ubuntu" | chpasswd

# config DNS
sudo service systemd-resolved stop
sudo systemctl disable systemd-resolved
sudo rm -Rf /etc/resolv.conf
cat <<EOF | sudo tee /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF


