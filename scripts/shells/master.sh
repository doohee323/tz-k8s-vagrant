#!/usr/bin/env bash

set -x

bash /vagrant/scripts/shells/base.sh

##################################################################
# k8s master
##################################################################

OUTPUT_FILE=/vagrant/join.sh
rm -rf /vagrant/join.sh
sudo kubeadm init --apiserver-advertise-address=192.168.1.10 --pod-network-cidr=172.16.0.0/16
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo kubeadm token create --print-join-command > /vagrant/join.sh
chmod +x $OUTPUT_FILE
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/master/manifests"
kubectl apply -f https://$raw_git/172.16_net_calico.yaml

kubectl proxy --accept-hosts='^*' &

## Copy config to local
cp /root/.kube/config /vagrant/config

echo "" >> ~/.bashrc
echo "alias ll='ls -al'" >> ~/.bashrc
echo "alias k='kubectl --kubeconfig ~/.kube/config'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
