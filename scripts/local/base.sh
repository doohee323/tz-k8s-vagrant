#!/usr/bin/env bash

#set -x

##################################################################
# k8s base
##################################################################

if [ -d /vagrant ]; then
  cd /vagrant
fi

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt install -y python3 python3-pip git

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

exit 0

ansible all -i kubespray/inventory/test-cluster/inventory.ini -m ping
