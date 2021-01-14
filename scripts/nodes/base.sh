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
sudo groupadd docker
sudo usermod -aG docker ubuntu

sudo mkdir -p /home/ubuntu/.ssh
sudo chown -Rf ubuntu:ubuntu /home/ubuntu
sudo chmod 700 /home/ubuntu/.ssh

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF

# config DNS
sudo service systemd-resolved stop
sudo systemctl disable systemd-resolved
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

# for local docker repo
echo '
{
  "group": "ubuntu",
  "insecure-registries" : [
    "192.168.1.10:5000",
    "192.168.2.2:5000"
  ]
}
' > /etc/docker/daemon.json

sudo chown -Rf ubuntu:ubuntu /var/run/docker.sock
sudo service docker restart

sudo mkdir -p /home/vagrant/data/postgres
sudo mkdir -p /home/vagrant/data/postgres-1
#sudo ln -s /home/vagrant/data /vagrant/data2

