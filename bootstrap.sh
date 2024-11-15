#!/bin/bash

set -x

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
elif [[ "$1" == "remove" ]]; then
  vagrant destroy -f
  exit 0
fi

echo -n "Do you want to make a jenkins on k8s in Vagrant Master / Slave? (M/S)"
read A_ENV
echo "A_ENV: ${A_ENV}"

MYKEY=tz_rsa
if [ ! -f .ssh/${MYKEY} ]; then
  mkdir -p .ssh \
    && cd .ssh \
    && ssh-keygen -t rsa -C ${MYKEY} -P "" -f ${MYKEY} -q
fi

cp -Rf Vagrantfile Vagrantfile.bak
if [[ "${A_ENV}" == "M" ]]; then
  echo "11111"
  cp -Rf ./scripts/local/Vagrantfile Vagrantfile
  #vagrant up --provider=virtualbox
  #vagrant ssh kube-master -- -t 'bash /vagrant/scripts/local/kubespray.sh'
elif [[ "${A_ENV}" == "S" ]]; then
  echo "111112"
  cp -Rf ./scripts/local/Vagrantfile_node Vagrantfile
  #vagrant up --provider=virtualbox
  #vagrant ssh kube-slave -- -t 'bash /vagrant/scripts/local/node.sh'
fi

mv Vagrantfile.bak Vagrantfile

exit 0

vagrant status
vagrant snapshot list

vagrant ssh kube-master
vagrant ssh kube-node-1
vagrant ssh kube-node-2

vagrant ssh kube-slave
vagrant ssh kube-slave-1
vagrant ssh kube-slave-2

vagrant reload
vagrant snapshot save kube-master kube-master_python --force

