#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

rm -Rf /root/.ssh
chown -R root:root /root/.ssh

sudo groupadd ubuntu
sudo useradd -g ubuntu -d /home/ubuntu -s /bin/bash -m ubuntu
cat <<EOF > pass.txt
ubuntu:hdh971097
EOF
sudo chpasswd < pass.txt

MYKEY=kubekey
[[ ! -f /root/.ssh/${MYKEY} ]] \
&& mkdir -p /root/.ssh \
&& rm -Rf /root/.ssh/${MYKEY}* \
&& ssh-keygen -f /root/.ssh/${MYKEY} -N '' -q \
&& chmod -Rf 600 /root/.ssh

cat /root/.ssh/${MYKEY}.pub > /vagrant/authorized_keys
cp -Rf /root/.ssh/${MYKEY}* /vagrant/ \
  && chmod -Rf 600 /vagrant/${MYKEY}*
cp -Rf /vagrant/authorized_keys /root/.ssh/authorized_keys
cat /root/.ssh/${MYKEY}.pub >> /home/vagrant/.ssh/authorized_keys

cat <<EOF > /root/.ssh/config
Host 192.168.*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentityFile /root/.ssh/kubekey
EOF

cp -Rf /root/.ssh/config /home/vagrant/.ssh/config
chown -Rf vagrant:vagrant /home/vagrant/.ssh/config

mkdir -p /root/.ssh \
  && cp -Rf /vagrant/authorized_keys /root/.ssh/ \
  && cp -Rf /vagrant/kubekey* /root/.ssh/ \
  && chown -Rf root:root /root/.ssh \
  && chmod -Rf 600 /root/.ssh.ssh/*

cd /vagrant
sudo rm -Rf kubespray
git clone --single-branch --branch v2.15.0 https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
sudo pip3 install -r requirements.txt
rm -Rf inventory/mycluster
cp -rfp inventory/sample inventory/mycluster

cp -Rf /vagrant/resource/kubespray/inventory.ini /vagrant/kubespray/inventory/mycluster/inventory.ini
cp -Rf /vagrant/resource/kubespray/addons.yml /vagrant/kubespray/inventory/mycluster/group_vars/k8s-cluster/addons.yml

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

exit 0

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.1.10/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet
kubectl get nodes -o wide

## nfs server
## !!! Warning: Authentication failure. Retrying... after nfs setting and vagrant up
sudo apt-get install nfs-common nfs-kernel-server rpcbind portmap -y
sudo mkdir -p /home/vagrant/data
sudo chmod -Rf 777 /home/vagrant/
#sudo chown -Rf nobody:nogroup /home/vagrant/
echo '/home/vagrant/data 192.168.1.0/16(rw,sync,no_subtree_check)' >> /etc/exports
exportfs -a
systemctl stop nfs-kernel-server
systemctl start nfs-kernel-server
#service nfs-kernel-server status
showmount -e 192.168.1.10
#sudo mkdir /data
#mount -t nfs -vvvv 192.168.1.10:/home/vagrant/data /data
#echo '192.168.1.10:/home/vagrant/data /data  nfs      defaults    0       0' >> /etc/fstab
#sudo mount -t nfs -o resvport,rw 192.168.3.1:/Volumes/workspace/etc /Volumes/sambashare

k patch storageclass nfs-storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

