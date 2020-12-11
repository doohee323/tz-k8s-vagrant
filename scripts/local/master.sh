#!/usr/bin/env bash

#set -x

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

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/master/manifests"
kubectl apply -f https://$raw_git/172.16_net_calico.yaml

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

##################################################################
# call monitoring install script
##################################################################
#bash /vagrant/scripts/local/dashboard.sh

##################################################################
# call monitoring install script
##################################################################
#bash /vagrant/scripts/monitor/monitor.sh

##################################################################
# call jenkins install script
##################################################################
#bash /vagrant/scripts/jenkins/install.sh


