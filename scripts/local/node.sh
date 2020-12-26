#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

## nfs ubuntu client
sudo apt-get install nfs-common
mkdir -p /home/vagrant/data
mount -t nfs -vvvv 192.168.1.10:/home/vagrant/data /home/vagrant/data
echo '192.168.1.10:/home/vagrant/data /home/vagrant/data  nfs      defaults    0       0' >> /etc/fstab

##################################################################
# k8s node
##################################################################
MY_IP=`ifconfig | grep '192.168.1.' | awk '{print $2}'`
sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=${MY_IP}/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet

sleep 30

sudo bash /vagrant/join.sh

cat /vagrant/info

exit 0

