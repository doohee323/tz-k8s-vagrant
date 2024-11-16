#!/usr/bin/env bash

#set -x

##################################################################
# k8s base
##################################################################

if [ -d /vagrant ]; then
  cd /vagrant
fi

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
#sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get update
sudo apt install -y python3 python3-pip git

cat <<EOF >> /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

sudo tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

#sudo ufw enable
sudo ufw allow 22
sudo ufw allow 6443
sudo ufw disable

sudo groupadd vagrant
sudo useradd -g vagrant -d /home/vagrant -s /bin/bash -m vagrant
cat <<EOF > pass.txt
vagrant:vagrant
EOF
sudo chpasswd < pass.txt

cat <<EOF >> /etc/hosts
# mac
kube-master     192.168.86.90
kube-node--1    192.168.86.91
kube-node--2    192.168.86.92

# ubuntu
kube-slave      192.168.86.97
kube-slave-1    192.168.86.98
kube-slave-2    192.168.86.99

# windows
kube-slave      192.168.86.94
kube-slave-1    192.168.86.95
kube-slave-2    192.168.86.96
EOF
