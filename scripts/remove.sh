#!/usr/bin/env bash

kubeadm reset
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube* -y
sudo apt-get autoremove -y
sudo rm -rf ~/.kube
sudo rm -Rf /etc/cni/net.d

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

service docker stop
sudo rm -Rf /var/lib/docker

cd /
du -h | sort -hr | head