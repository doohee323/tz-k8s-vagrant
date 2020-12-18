#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

##################################################################
# k8s node
##################################################################

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.1.12/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet

sleep 30

sudo bash /vagrant/join.sh

cat /vagrant/info

exit 0

