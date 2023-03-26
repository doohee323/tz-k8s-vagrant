#!/bin/bash

#set -x

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${WORKING_DIR}

if [[ "$1" == "reload" ]]; then
  echo "Vagrant reload!"
  vagrant reload
  exit 0
elif [[ "$1" == "halt" ]]; then
  echo "Vagrant halt!"
  vagrant halt
  exit 0
elif [[ "$1" == "down" ]]; then
  if [[ -f "./tz-aws-terraform/terraform.tfstate" ]]; then
      cp -Rf Vagrantfile Vagrantfile.bak
      cp -Rf ./scripts/terraform/Vagrantfile Vagrantfile
      vagrant ssh -- -t 'bash /vagrant/scripts/terraform/remove_all.sh'
      mv Vagrantfile.bak Vagrantfile
  else
      bash ./scripts/local/remove_all.sh
  fi
  vagrant destroy -f
  exit 0
fi

echo -n "Do you want to make a jenkins on k8s in Vagrant or AWS? (V/A)"
read A_ENV

cp -Rf Vagrantfile Vagrantfile.bak
if [[ "${A_ENV}" == "" || "${A_ENV}" == "V" ]]; then
  cp -Rf ./scripts/local/Vagrantfile Vagrantfile
  vagrant up
  vagrant ssh kube-master -- -t 'bash /vagrant/scripts/local/kubespray.sh'
fi
if [[ "${A_ENV}" == "A" ]]; then
  if [[ ! -f "./tz-aws-terraform/resource/aws/credentials" ]]; then
    echo "There is no AWS config in ./tz-aws-terraform/resource/aws/credentials!"
    exit 1
  fi
  cp -Rf ./scripts/terraform/Vagrantfile Vagrantfile
  vagrant up
fi

mv Vagrantfile.bak Vagrantfile

exit 0

vagrant snapshot list

vagrant snapshot save kube-master k8s-master_python --force
vagrant snapshot save kube-node1 node-1_python --force
vagrant snapshot save kube-node2 node-2_python --force

vagrant snapshot save kube-master k8s-master_kafka --force
vagrant snapshot save kube-node1 node-1_kafka --force
vagrant snapshot save kube-node2 node-2_kafka --force

vagrant snapshot save kube-master k8s-master_nexus --force
vagrant snapshot save kube-node1 node-1_nexus --force
vagrant snapshot save kube-node2 node-2_nexus --force

vagrant snapshot save kube-master k8s-master_rancher --force
vagrant snapshot save kube-node1 node-1_rancher --force
vagrant snapshot save kube-node2 node-2_rancher --force

vagrant snapshot save kube-master k8s-master_master --force
vagrant snapshot save kube-node1 node-1_master --force
vagrant snapshot save kube-node2 node-2_master --force

vagrant snapshot restore kube-master k8s-master_latest
vagrant snapshot restore kube-node1 node-1_latest
vagrant snapshot restore kube-node2 node-2_latest

vagrant snapshot restore kube-master k8s-master_kafka
vagrant snapshot restore kube-node1 node-1_kafka
vagrant snapshot restore kube-node2 node-2_kafka

vagrant snapshot restore kube-master k8s-master_nexus
vagrant snapshot restore kube-node1 node-1_nexus
vagrant snapshot restore kube-node2 node-2_nexus

vagrant snapshot restore kube-master k8s-master_rancher
vagrant snapshot restore kube-node1 node-1_rancher
vagrant snapshot restore kube-node2 node-2_rancher

vagrant snapshot restore kube-master k8s-master_master
vagrant snapshot restore kube-node1 node-1_master
vagrant snapshot restore kube-node2 node-2_master

