#!/bin/bash

# remove comment if you want to enable debugging
#set -x

sudo mkdir -p /home/vagrant/.aws

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.13.5"
# create new ssh key
#[[ ! -f /home/vagrant/.ssh/mykeypair ]] \
#&& mkdir -p /home/vagrant/.ssh \
#&& ssh-keygen -f /home/vagrant/.ssh/mykeypair -N '' \
#&& chown -R vagrant:vagrant /home/vagrant/.ssh
[[ ! -f /home/vagrant/.ssh/mykeypair ]] \
&& mkdir -p /home/vagrant/.ssh \
&& ssh-keygen -t rsa -C mykeypair -P "" -f /home/vagrant/.ssh/mykeypair -q \
&& chown -R vagrant:vagrant /home/vagrant/.ssh \
&& chmod -Rf 600 /home/vagrant/.ssh/mykeypair*

# install packages
apt-get update
apt-get -y install docker.io ansible unzip python3-pip

# add docker privileges
usermod -G docker vagrant
# install awscli and ebcli
pip3 install -U awscli
pip3 install -U awsebcli

#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi

############################################################
## build jenkins env.
############################################################
bash /vagrant/scripts/terraform/build_all.sh

exit 0



