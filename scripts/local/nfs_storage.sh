#!/usr/bin/env bash

##########################################
## nfs server
##########################################

sudo apt-get install nfs-common nfs-kernel-server rpcbind portmap y
mkdir /Volumes/workspace/etc/tz-k8s-vagrant/data
sudo chmod -R 777 /Volumes/workspace/etc/tz-k8s-vagrant/data

echo '' >> /etc/exports
echo '/Volumes/workspace/etc/tz-k8s-vagrant/data 192.168.0.0/16(rw,sync,no_subtree_check)' >> /etc/exports

exportfs -a
systemctl restart nfs-kernel-server

showmount -e 192.168.0.143
Export list for 192.168.0.143:
/media/doohee323/Volumes/workspace/etc/tz-k8s-vagrant/data 192.168.0.0/16

## nfs ubuntu client
sudo apt-get install nfs-common
mkdir -p /Volumes/workspace/etc/tz-k8s-elk/data
mount -t nfs -vvvv 192.168.0.143:/Volumes/workspace/etc/tz-k8s-vagrant/data /Volumes/workspace/etc/tz-k8s-elk/data

## nfs macos client
mkdir -p /Volumes/workspace/etc/tz-k8s-elk/data
sudo mount -o resvport,rw -t nfs -vvvv 192.168.0.143:/Volumes/workspace/etc/tz-k8s-vagrant/data /Volumes/workspace/etc/tz-k8s-elk/data

