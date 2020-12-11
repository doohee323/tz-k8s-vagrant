#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

##################################################################
# k8s node
##################################################################

sudo bash /vagrant/join.sh

sleep 30

echo "##################################################################"
echo "Install other services in k8s-master"
echo "##################################################################"
bash /vagrant/scripts/local/others.sh
