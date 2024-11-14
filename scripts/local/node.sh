#!/usr/bin/env bash

sudo apt update
sudo apt install python3-pip net-tools -y

MYKEY=tz_rsa
cp -Rf /vagrant/.ssh/${MYKEY} /root/.ssh/${MYKEY}
cp -Rf /vagrant/.ssh/${MYKEY}.pub /root/.ssh/${MYKEY}.pub
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
cat /root/.ssh/${MYKEY}.pub >> /root/.ssh/authorized_keys
chown -R root:root /root/.ssh \
  chmod -Rf 600 /root/.ssh
rm -Rf /home/vagrant/.ssh \
  && cp -Rf /root/.ssh /home/vagrant/.ssh \
  && chown -Rf vagrant:vagrant /home/vagrant/.ssh \
  && chmod -Rf 700 /home/vagrant/.ssh \
  && chmod -Rf 600 /home/vagrant/.ssh/*

