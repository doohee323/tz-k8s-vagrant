#!/usr/bin/env bash

#set -x

bash /vagrant/scripts/local/base.sh

sudo apt update
sudo apt install python3-pip net-tools -y
