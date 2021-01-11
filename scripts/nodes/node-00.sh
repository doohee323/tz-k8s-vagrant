#!/usr/bin/env bash

set -x

##################################################################
# k8s node
##################################################################
# config DNS
sudo service systemd-resolved stop
sudo systemctl disable systemd-resolved
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "ubuntu"
}
EOF

sudo service docker restart
sudo systemctl enable docker

sudo groupadd ubuntu
sudo useradd -m ubuntu -g ubuntu -s /bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
sudo mkdir /home/ubuntu
sudo chown ubuntu:ubuntu /home/ubuntu
sudo groupadd docker
sudo usermod -aG docker ubuntu

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF

sudo mkdir -p /home/ubuntu/.ssh
sudo chown -Rf ubuntu:ubuntu /home/ubuntu
sudo chmod 700 /home/ubuntu/.ssh
sudo chown -Rf ubuntu:ubuntu /var/run/docker.sock
docker ps

exit 0
