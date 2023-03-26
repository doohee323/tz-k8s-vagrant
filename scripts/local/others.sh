#!/usr/bin/env bash

#set -x

#INC_CNT=0
#TARGET_CNT=2
#MAX_CNT=50
#while true; do
#  sleep 10
#  INST_CNT=`k get nodes | grep Ready | wc | awk '{print $1}'`
#  if [[ $INST_CNT == $TARGET_CNT || $INC_CNT == $MAX_CNT ]]; then
#    break
#  fi
#  let "INC_CNT=INC_CNT+1"
#done

sudo chown -Rf vagrant:vagrant /var/run/docker.sock

#k delete -f /vagrant/tz-local/resource/standard-storage.yaml
k apply -f /vagrant/tz-local/resource/standard-storage.yaml
k patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

# nfs
# 1. with helm
#helm install my-release --set nfs.server=192.168.1.10 --set nfs.path=/srv/nfs/mydata stable/nfs-client-provisioner
# 2. with manual
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/static-nfs.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/serviceaccount.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/nfs.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/nfs-claim.yaml

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

sleep 10

helm repo add stable https://charts.helm.sh/stable
helm repo update

#k get po -n kube-system

sudo rm -Rf /vagrant/info

##################################################################
# call nfs dynamic-provisioning
##################################################################
bash /vagrant/tz-local/resource/dynamic-provisioning/nfs/install.sh

##################################################################
# call metallb
##################################################################
bash /vagrant/tz-local/resource/metallb/install.sh

##################################################################
# call dashboard install script
##################################################################
bash /vagrant/tz-local/resource/dashboard/install.sh

##################################################################
# call monitoring install script
##################################################################
bash /vagrant/tz-local/resource/monitoring/install.sh

##################################################################
# call jenkins install script
##################################################################
bash /vagrant/tz-local/resource/jenkins/install.sh

##################################################################
# call tz-py-crawler app in k8s
##################################################################
#bash /vagrant/tz-local/resource/tz-py-crawler/install.sh

exit 0

bash /vagrant/tz-local/resource/kafka/install.sh