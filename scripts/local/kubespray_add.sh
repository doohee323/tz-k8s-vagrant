#!/usr/bin/env bash

# add a new node
#https://www.techbeatly.com/adding-new-nodes-to-kubespray-managed-kubernetes-cluster/

#set -x

if [ -d /vagrant ]; then
  cd /vagrant
fi

cp -Rf resource/kubespray/inventory2.ini kubespray/inventory/test-cluster/inventory.ini

cd kubespray
ansible all -i inventory/test-cluster/inventory.ini -m ping

ansible-playbook -i inventory/test-cluster/hosts.yaml cluster.yml -b -become-user=root -l node3

exit 0
