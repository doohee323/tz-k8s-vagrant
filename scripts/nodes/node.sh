#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

exit 0

## nfs ubuntu client
sudo apt-get install nfs-common
mkdir -p /data
mount -t nfs -vvvv 192.168.1.10:/home/vagrant/data /data
echo '192.168.1.10:/home/vagrant/data /data  nfs      defaults    0       0' >> /etc/fstab

