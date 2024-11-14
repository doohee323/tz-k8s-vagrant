#!/usr/bin/env bash

#set -x

if [ -d /vagrant ]; then
  cd /vagrant
fi

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

MYKEY=tz_rsa
cp -Rf /vagrant/.ssh/${MYKEY} /root/.ssh/${MYKEY}
cp -Rf /vagrant/.ssh/${MYKEY}.pub /root/.ssh/${MYKEY}.pub
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
cat /root/.ssh/${MYKEY}.pub >> /root/.ssh/authorized_keys
chown -R root:root /root/.ssh \
  chmod -Rf 600 /root/.ssh
rm -Rf /home/vagrant/.ssh \
  && cp -Rf /root/.ssh /home/vagrant/.ssh \
  && chown -Rf vagrant:vagrant /home/vagrant/.ssh \
  && chmod -Rf 700 /home/vagrant/.ssh \
  && chmod -Rf 600 /home/vagrant/.ssh/*

cat <<EOF > /root/.ssh/config
Host kube-master
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  User vagrant
  IdentityFile ~/.ssh/tz_rsa

Host kube-node1
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User vagrant
  IdentityFile ~/.ssh/tz_rsa

Host kube-node2
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User vagrant
  IdentityFile ~/.ssh/tz_rsa

Host 192.168.1.10
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  User vagrant
  IdentityFile ~/.ssh/tz_rsa

Host 192.168.1.11
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User vagrant
  IdentityFile ~/.ssh/tz_rsa

Host 192.168.1.12
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User vagrant
  IdentityFile ~/.ssh/tz_rsa
EOF

bash scripts/local/base.sh

sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install python3-pip ansible net-tools -y

sudo bash scripts/local/kubespray.sh

exit 0

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.1.10/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload && systemctl restart kubelet
kubectl get nodes -o wide

## nfs server
## !!! Warning: Authentication failure. Retrying... after nfs setting and ubuntu up
sudo apt-get install nfs-common nfs-kernel-server rpcbind portmap -y
sudo mkdir -p /homedata
sudo chmod -Rf 777 /home
#sudo chown -Rf nobody:nogroup /home
echo '/homedata 192.168.1.0/16(rw,sync,no_subtree_check)' >> /etc/exports
exportfs -a
systemctl stop nfs-kernel-server
systemctl start nfs-kernel-server
#service nfs-kernel-server status
showmount -e 192.168.1.10
#sudo mkdir /data
#mount -t nfs -vvvv 192.168.1.10:/homedata /data
#echo '192.168.1.10:/homedata /data  nfs      defaults    0       0' >> /etc/fstab
#sudo mount -t nfs -o resvport,rw 192.168.3.1:/Volumes/workspace/etc /Volumes/sambashare

k patch storageclass nfs-storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

