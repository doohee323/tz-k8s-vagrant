#!/bin/bash

#set -x

if [[ "$1" == "down" ]]; then
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
  vagrant ssh k8s-master -- -t 'bash /vagrant/scripts/local/others.sh'
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