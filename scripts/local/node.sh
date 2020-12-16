#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

##################################################################
# k8s node
##################################################################

sudo bash /vagrant/join.sh

sleep 30

echo "##################################################################"
echo "Install other services in k8s-master"
echo "##################################################################"
bash /vagrant/scripts/local/others.sh

exit 0

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.1.12/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet

