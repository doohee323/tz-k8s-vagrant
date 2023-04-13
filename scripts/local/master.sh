#!/usr/bin/env bash

#set -x

if [ -d /ubuntu ]; then
  cd /ubuntu
fi

exit 0

bash scripts/local/base.sh

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

cat <<EOF >> /etc/hosts
192.168.86.30    node1
192.168.86.27    node2
192.168.86.36    node3
EOF

sudo groupadd ubuntu
sudo useradd -g ubuntu -d /home/ubuntu -s /bin/bash -m ubuntu
cat <<EOF > pass.txt
ubuntu:hdh971097
EOF
sudo chpasswd < pass.txt

MYKEY=id_rsa
[[ ! -f /root/.ssh/${MYKEY} ]] \
  && mkdir -p /root/.ssh \
  && rm -Rf /root/.ssh/${MYKEY}* \
  && ssh-keygen -t rsa -C ${MYKEY} -P "" -f ${MYKEY} -q \
  && chown -R root:root /root/.ssh \
  && chmod -Rf 600 /root/.ssh

cat /root/.ssh/${MYKEY}.pub > authorized_keys
mkdir -p /home/ubuntu/.ssh
cp -Rf /root/.ssh/${MYKEY}* . \
  && chmod -Rf 600 ${MYKEY}*
if [ -d /ubuntu ]; then
  cp -Rf authorized_keys /root/.ssh/authorized_keys
else
  cat authorized_keys >> /root/.ssh/authorized_keys
fi
cat /root/.ssh/${MYKEY}.pub >> /home/ubuntu/.ssh/authorized_keys
chown -Rf ubuntu:ubuntu /home/ubuntu/.ssh

cat <<EOF > /root/.ssh/config
Host node1
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  User ubuntu
  IdentityFile ~/.ssh/id_rsa

Host node2
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User ubuntu
  IdentityFile ~/.ssh/id_rsa

Host node3
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  User ubuntu
  IdentityFile ~/.ssh/id_rsa
EOF

cp -Rf /root/.ssh/config /home/ubuntu/.ssh/config
chown -Rf ubuntu:ubuntu /home/ubuntu/.ssh/config

mkdir -p /root/.ssh \
  && cp -Rf authorized_keys /root/.ssh/ \
  && cp -Rf ${MYKEY}* /root/.ssh/ \
  && chown -Rf root:root /root/.ssh \
  && chmod -Rf 600 /root/.ssh/*

sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y

sudo rm -Rf kubespray
git clone --single-branch https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
sudo pip3 install -r requirements.txt
rm -Rf inventory/test-cluster
cp -rfp inventory/sample inventory/test-cluster

cd ..
cp -Rf resource/kubespray/inventory.ini kubespray/inventory/test-cluster/inventory.ini
#cp -Rf resource/kubespray/hosts.yaml kubespray/inventory/test-cluster/hosts.yaml
cp -Rf resource/kubespray/addons.yml kubespray/inventory/test-cluster/group_vars/k8s_cluster/addons.yml

bash scripts/local/kubespray.sh

exit 0

sudo sed -i "s/\$KUBELET_EXTRA_ARGS/\$KUBELET_EXTRA_ARGS --node-ip=192.168.0.127/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
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
showmount -e 192.168.0.127
#sudo mkdir /data
#mount -t nfs -vvvv 192.168.0.127:/homedata /data
#echo '192.168.0.127:/homedata /data  nfs      defaults    0       0' >> /etc/fstab
#sudo mount -t nfs -o resvport,rw 192.168.3.1:/Volumes/workspace/etc /Volumes/sambashare

k patch storageclass nfs-storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

