#!/usr/bin/env bash

# add a new node
#https://www.techbeatly.com/adding-new-nodes-to-kubespray-managed-kubernetes-cluster/

#set -x

if [ -d /vagrant ]; then
  cd /vagrant
fi

#cp -Rf resource/kubespray/inventory_add.ini kubespray/inventory/test-cluster/inventory.ini
cp -Rf scripts/local/config.cfg /root/.ssh/config

ansible all -i resource/kubespray/inventory_add.ini -m ping -u root

#ansible-playbook -i inventory/test-cluster/hosts.yaml cluster.yml -b -become-user=root -l node3
ansible-playbook -u root -i resource/kubespray/inventory_add.ini \
  --private-key .ssh/tz_rsa --become --become-user=root \
  kubespray/cluster.yml -b -l kube-slave-1,kube-slave-2,kube-slave-3,kube-slave-4,kube-slave-5

#ansible-playbook -u root -i resource/kubespray/inventory_add.ini \
#  --private-key .ssh/tz_rsa --become --become-user=root \
#  kubespray/cluster.yml

exit 0
