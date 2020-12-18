#!/bin/bash

#set -x

TZ_PROJECT=tz-aws-terraform

cd /vagrant/${TZ_PROJECT}

sudo rm -Rf /home/vagrant/.aws/config

############################################################
# make aws credentials
############################################################
if [ ! -f "/home/vagrant/.aws/config" ]; then
	sudo cp -Rf /vagrant/${TZ_PROJECT}/resource/aws/config /home/vagrant/.aws/config
	sudo cp -Rf /vagrant/${TZ_PROJECT}/resource/aws/credentials /home/vagrant/.aws/credentials
	chown -Rf vagrant:vagrant /home/vagrant/.aws
	chmod -Rf 600 /home/vagrant/.aws/*
	
	rm -Rf /root/.aws
	cp -Rf /home/vagrant/.aws /root/.aws
	chmod -Rf 600 /root/.aws.aws/*
fi

if [ ! -f "/vagrant/${TZ_PROJECT}/s3_bucket_id" ]; then
	LC_ALL=C;
	random_str=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w ${1:-6} | head -n 1`
	echo aws s3api create-bucket --bucket terraform-state-${random_str} --region us-west-1
	aws s3api create-bucket \
	  --bucket terraform-state-${random_str} \
	  --region us-west-1 \
	  --create-bucket-configuration LocationConstraint=us-west-1
fi

sudo rm -Rf .terraform
sudo rm -Rf terraform.tfstate
sudo rm -Rf terraform.tfstate.backup
sudo rm -Rf mykeypair*

############################################################
## make a ssh key
############################################################
ssh-keygen -t rsa -C mykeypair -P "" -f mykeypair -q
sudo mv mykeypair* /home/vagrant/.ssh
sudo chown -Rf vagrant:vagrant /home/vagrant/.ssh
sudo chmod -Rf 600 /home/vagrant/.ssh/mykeypair*

############################################################
## make instances in aws
############################################################

MY_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
sudo sed -i "s|255.255.255.255|${MY_IP}|g" /vagrant/tz-aws-terraform/variables.tf

## validate terraform scripts
sudo apt install python3-pip
#pip3 install --upgrade pip && pip3 install --upgrade setuptools
#pip3 install checkov
python3 -m pip install checkov
python3 -m pip install dataclasses
checkov -d /vagrant/tz-aws-terraform > /home/vagrant/validate.log

## run terraform scripts
echo terraform init
terraform init
echo terraform apply -auto-approve
terraform apply -auto-approve

if [ $? != 0 ]; then
  echo "fail to apply terraform"
  exit 1
fi

# restore
sudo sed -i "s|${MY_IP}|255.255.255.255|g" /vagrant/tz-aws-terraform/variables.tf

mkdir -p /home/vagrant/.kube
cluster_name=`terraform output | grep "cluster_name" | awk '{print $3}'`
sudo mv ${cluster_name}.conf /home/vagrant/.kube/config

kubectl --kubeconfig /home/vagrant/.kube/config apply -f /vagrant/${TZ_PROJECT}/resource/172.16_net_calico.yaml

kubectl --kubeconfig /home/vagrant/.kube/config get nodes
kubectl --kubeconfig /home/vagrant/.kube/config get all --all-namespaces

export s3_bucket_id=`terraform output | grep s3-bucket | awk '{print $3}'`
echo $s3_bucket_id > s3_bucket_id
master_ip=`terraform output | grep -A 2 "public_ip" | head -n 1 | awk '{print $3}'`
export master_ip=`echo $master_ip | sed -e 's/\"//g;s/ //;s/,//'`
private_ip=`terraform output | grep -A 2 "private_ip" | head -n 1 | awk '{print $3}'`
export private_ip=`echo $private_ip | sed -e 's/\"//g;s/ //;s/,//'`

sudo mkdir -p /home/vagrant/.ssh
echo '
Host MASTER_IP
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
' >> /home/vagrant/.ssh/config
sudo sed -i "s|MASTER_IP|${master_ip}|g" /home/vagrant/.ssh/config

echo '
alias ll="ls -al"
alias k="kubectl --kubeconfig ~/.kube/config"
complete -F __start_kubectl k
export TZ_PROJECT=PROJECT_NAME
' > /home/vagrant/.bashrc
sudo sed -i "s|PROJECT_NAME|${TZ_PROJECT}|g" /home/vagrant/.bashrc
source /home/vagrant/.bashrc

sudo cp -Rf /home/vagrant/.bashrc /root/.bashrc
sudo cp -Rf /home/vagrant/.kube/config /root/.kube/config

kubectl --kubeconfig /home/vagrant/.kube/config get nodes
kubectl --kubeconfig /home/vagrant/.kube/config get all --all-namespaces

echo '
##[ Summary ]##########################################################
- Access to master instance
  vagrant ssh
  ssh -i ~/.ssh/mykeypair ubuntu@MASTER_IP
- Using kubectl
  sudo su
  k get all --all-namespaces
- Destroy aws resources
  bash /vagrant/scripts/terraform/remove_all.sh
  vagrant destroy -f  # in the outside of vagrant
#######################################################################
' > /vagrant/info
sudo sed -i "s|MASTER_IP|${master_ip}|g" /vagrant/info
cat /vagrant/info

############################################################
## install K8S monitoring tools in aws
############################################################
bash /vagrant/${TZ_PROJECT}/scripts/monitor.sh

############################################################
## install jenkins in the K8S
############################################################
bash /vagrant/${TZ_PROJECT}/resource/jenkins/install.sh

exit 0
