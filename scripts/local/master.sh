#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

bash /vagrant/scripts/local/base.sh

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

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.1.10/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet
kubectl get nodes -o wide

sleep 30

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# raw_address for gitcontent
kubectl --kubeconfig ~/.kube/config apply -f /vagrant/tz-local/resource/172.16_net_calico.yaml

kubectl proxy --accept-hosts='^*' &

## Copy config to local
sudo mkdir -p /home/vagrant/.kube
sudo cp /root/.kube/config /home/vagrant/.kube/config
sudo chown -Rf vagrant:vagrant /home/vagrant/.kube
sudo cp /root/.kube/config /vagrant/config

echo '
alias ll="ls -al"
alias k="kubectl --kubeconfig ~/.kube/config"
complete -F __start_kubectl k
' > ~/.bashrc
source ~/.bashrc
sudo cp -Rf ~/.bashrc /home/vagrant/.bashrc
sudo chown -Rf vagrant:vagrant /home/vagrant/.bashrc

echo "##################################################################"
echo "Install other services in k8s-master"
echo "##################################################################"
sudo bash /vagrant/scripts/local/others.sh


