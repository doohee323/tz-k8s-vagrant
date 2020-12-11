#!/usr/bin/env bash

#set -x

sudo chown -Rf vagrant:vagrant /var/run/docker.sock

##################################################################
# call monitoring install script
##################################################################
bash /vagrant/tz-local/dashboard.sh

##################################################################
# call monitoring install script
##################################################################
bash /vagrant/tz-local/monitor.sh

##################################################################
# call jenkins install script
##################################################################
bash /vagrant/tz-local/resource/jenkins/install.sh

