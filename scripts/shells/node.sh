#!/usr/bin/env bash

set -x

bash /vagrant/scripts/shells/base.sh

##################################################################
# k8s node
##################################################################

sudo /vagrant/join.sh