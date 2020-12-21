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

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

sleep 10

helm repo add stable https://charts.helm.sh/stable
helm repo update

#k get po -n kube-system

#export HELM_HOST=localhost:44134

sudo rm -Rf /vagrant/info

##################################################################
# call dashboard install script
##################################################################
bash /vagrant/tz-local/resource/dashboard/install.sh

##################################################################
# call es install script
##################################################################
bash /vagrant/tz-local/resource/monitoring/es.sh

exit 0

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
bash /vagrant/tz-local/resource/tz-py-crawler.sh

exit 0
