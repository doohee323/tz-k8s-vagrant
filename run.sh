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

MYKEY=tz_rsa
mkdir -p .ssh \
  && cd .ssh \
  && ssh-keygen -t rsa -C ${MYKEY} -P "" -f ${MYKEY} -q

if [[ "${A_ENV}" == "" || "${A_ENV}" == "V" ]]; then
  vagrant up
  vagrant ssh kube-master -- -t 'bash /vagrant/scripts/local/kubespray.sh'
fi

mv Vagrantfile.bak Vagrantfile

exit 0

vagrant ssh kube-master
vagrant ssh kube-node-1

vagrant snapshot list

vagrant snapshot save kube-master kube-master_python --force
