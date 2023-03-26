#!/usr/bin/env bash

#set -x

##################################################################
# k8s base
##################################################################

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt install -y python3 python3-pip git

exit 0

ssh -i ~/.ssh/kubekey vagrant@192.168.1.10
ssh -i ~/.ssh/kubekey vagrant@192.168.1.12
ssh -i ~/.ssh/kubekey vagrant@192.168.1.13

ansible all -i /vagrant/kubespray/inventory/mycluster/inventory.ini -m ping



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
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq
yq --version

sudo groupadd ubuntu
sudo useradd -g ubuntu -d /home/ubuntu -s /bin/bash -m ubuntu
cat <<EOF > pass.txt
ubuntu:ubuntu
EOF
sudo chpasswd < pass.txt

# config DNS
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

# for local docker repo
echo '
{
        "insecure-registries" : [
          "192.168.1.10:5000",
          "192.168.2.2:5000"
        ]
}
' > /etc/docker/daemon.json

sudo service docker restart


