#!/usr/bin/env bash

# add a new node
#https://www.techbeatly.com/adding-new-nodes-to-kubespray-managed-kubernetes-cluster/

#set -x

if [ -d /vagrant ]; then
  cd /vagrant
fi

cd kubespray
ansible all -i resource/kubespray/inventory.ini -m ping -u root

#ansible-playbook -i inventory/test-cluster/hosts.yaml cluster.yml -b -become-user=root -l node3
ansible-playbook -u root -i resource/kubespray/inventory_add.ini \
  --private-key .ssh/tz_rsa --become --become-user=root \
  kubespray/cluster.yml -b -l kube-slave-6

exit 0
