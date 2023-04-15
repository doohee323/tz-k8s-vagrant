#!/usr/bin/env bash

export PROJECT_BASE='/vagrant/terraform-aws-k8s/workspace/base'

cd /vagrant

sudo mkdir -p /home/vagrant/.aws
sudo cp -Rf /vagrant/resources/config /home/vagrant/.aws/config
sudo cp -Rf /vagrant/resources/credentials /home/vagrant/.aws/credentials
sudo cp -Rf /vagrant/resources/project /home/vagrant/.aws/project
sudo chown -Rf vagrant:vagrant /home/vagrant/.aws
sudo rm -Rf /root/.aws
sudo cp -Rf /home/vagrant/.aws /root/.aws

sudo mkdir -p /home/vagrant/.kube
sudo cp -Rf /vagrant/resources/kubeconfig_${k8s_project} /home/vagrant/.kube/config
sudo chown -Rf vagrant:vagrant /home/vagrant/.kube
sudo rm -Rf /root/.kube
sudo cp -Rf /home/vagrant/.kube /root/.kube

git config --global --add safe.directory '*'

cp -Rf /vagrant/resources/${k8s_project} ${PROJECT_BASE}
cp -Rf /vagrant/resources/${k8s_project}.pub ${PROJECT_BASE}
cp -Rf /vagrant/resources/kubeconfig_${k8s_project} ${PROJECT_BASE}
cp -Rf /vagrant/resources/.auto.tfvars ${PROJECT_BASE}

cd ${PROJECT_BASE}
if [ ! -d "${PROJECT_BASE}/.terraform" ]; then
  rm -Rf ${k8s_project}*
  ssh-keygen -t rsa -C ${k8s_project} -P "" -f ${k8s_project} -q
  chmod -Rf 600 ${k8s_project}*
  mkdir -p /home/vagrant/.ssh
  cp -Rf ${k8s_project}* /home/vagrant/.ssh
  cp -Rf ${k8s_project}* /vagrant/resources
  chown -Rf vagrant:vagrant /home/vagrant/.ssh
  chown -Rf vagrant:vagrant /vagrant/resources

  rm -Rf ${PROJECT_BASE}/lb2.tf

  terraform init
  terraform plan -var-file=".auto.tfvars"
  terraform apply -var-file=".auto.tfvars" -auto-approve

  if [[ $? != 0 ]]; then
    echo "############ failed provisioning! ############"
    terraform destroy -auto-approve
    bash /vagrant/scripts/k8s_remove_all.sh
#    bash /vagrant/scripts/k8s_remove_all.sh cleanTfFiles
    exit 1
  fi

  export KUBECONFIG=`ls kubeconfig_${k8s_project}*`
  cp -Rf ${KUBECONFIG} /vagrant/resources/config_${k8s_project}

  sudo mkdir -p /root/.kube
  sudo cp -Rf ${KUBECONFIG} /root/.kube/config
  sudo chmod -Rf 600 /root/.kube/config
  mkdir -p /home/vagrant/.kube
  cp -Rf ${KUBECONFIG} /home/vagrant/.kube/config
  sudo chmod -Rf 600 /home/vagrant/.kube/config
  export KUBECONFIG=/home/vagrant/.kube/config
  sudo chown -Rf vagrant:vagrant /home/vagrant

  cp -Rf lb2.tf_ori lb2.tf

  terraform init
  terraform plan -var-file=".auto.tfvars"
  terraform apply -var-file=".auto.tfvars" -auto-approve

  bash /vagrant/scripts/k8s_addtion.sh

  echo "
  ##[ Summary ]##########################################################
    - in Docker
      export KUBECONFIG='/vagrant/config_${k8s_project}'

    - outside of Docker
      export KUBECONFIG='terraform-aws-k8s/workspace/base/kubeconfig_${k8s_project}'

    - kubectl get nodes
    - S3 bucket: ${s3_bucket_id}
  #######################################################################
  " > /vagrant/info
fi

cat /vagrant/info

exit 0
