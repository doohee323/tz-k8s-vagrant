#!/usr/bin/env bash

set -x

bash /vagrant/scripts/shells/base.sh

##################################################################
# k8s master
##################################################################

OUTPUT_FILE=/vagrant/join.sh
rm -rf /vagrant/join.sh
sudo kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=10.244.0.0/16
sudo kubeadm token create --print-join-command > /vagrant/join.sh
chmod +x $OUTPUT_FILE
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl proxy --accept-hosts='^*' &

## Copy config to local
cp /root/.kube/config /vagrant/config


