#!/usr/bin/env bash

#set -x

if [ -d /ubuntu ]; then
  cd /ubuntu
fi

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

MYKEY=id_rsa
[[ ! -f /root/.ssh/${MYKEY} ]] \
  && mkdir -p /root/.ssh \
  && rm -Rf /root/.ssh/${MYKEY}* \
  && ssh-keygen -t rsa -C ${MYKEY} -P "" -f ${MYKEY} -q \
  && chown -R root:root /root/.ssh \
  && chmod -Rf 600 /root/.ssh

cat /root/.ssh/${MYKEY}.pub >> authorized_keys
mkdir -p /home/ubuntu/.ssh
chmod -Rf 600 ${MYKEY}*

cat <<EOF > /root/.ssh/config
Host master
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  User ubuntu
  IdentityFile ~/.ssh/id_rsa

Host node1
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User ubuntu
  IdentityFile ~/.ssh/id_rsa

Host node2
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User ubuntu
  IdentityFile ~/.ssh/id_rsa
EOF

mkdir -p /home/ubuntu/.ssh \
  && cp -Rf authorized_keys /home/ubuntu/.ssh/ \
  && cp -Rf ${MYKEY}* /home/ubuntu/.ssh/ \
  && chown -Rf ubuntu:ubuntu /home/ubuntu/.ssh \
  && chmod -Rf 600 /home/ubuntu/.ssh/*

bash scripts/local/base.sh

sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y

sudo bash scripts/local/kubespray.sh

exit 0

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.0.20/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
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
showmount -e 192.168.0.20
#sudo mkdir /data
#mount -t nfs -vvvv 192.168.0.20:/homedata /data
#echo '192.168.0.20:/homedata /data  nfs      defaults    0       0' >> /etc/fstab
#sudo mount -t nfs -o resvport,rw 192.168.3.1:/Volumes/workspace/etc /Volumes/sambashare

k patch storageclass nfs-storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

