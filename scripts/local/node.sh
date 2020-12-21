#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

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

