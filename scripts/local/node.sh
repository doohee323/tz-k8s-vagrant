#!/usr/bin/env bash

#set -x

mkdir -p /root/.ssh \
  && cat /vagrant/authorized_keys >> /root/.ssh/authorized_keys \
  && cp -Rf /vagrant/id_rsa* /root/.ssh/ \
  && chown -Rf root:root /root/.ssh \
  && chmod -Rf 600 /root/.ssh/*

exit 0

bash /vagrant/scripts/local/base.sh

exit 0

## nfs ubuntu client
sudo apt-get install nfs-common
mkdir -p /data
mount -t nfs -vvvv 192.168.0.127:/root/data /data
echo '192.168.0.127:/root/data /data  nfs      defaults    0       0' >> /etc/fstab

