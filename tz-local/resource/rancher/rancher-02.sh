#!/usr/bin/env bash

########################################################################
# - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://10.0.0.10/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
## you can get kube_config_cluster.yml from Dashboard: local's Kubeconfig File
## in https://192.168.0.184/c/local/monitoring
su - ubuntu
curl --insecure -sfL https://192.168.0.184/v3/import/ksbrj5qbq4485jt5gc4j8xp6x97pvwf4jkl97vg4jcprbzknpbmgrj.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

or

wget https://192.168.0.184/v3/import/ksbrj5qbq4485jt5gc4j8xp6x97pvwf4jkl97vg4jcprbzknpbmgrj.yaml --no-check-certificate
kubectl apply -f ksbrj5qbq4485jt5gc4j8xp6x97pvwf4jkl97vg4jcprbzknpbmgrj.yaml --kubeconfig ~/.kube/config

########################################################################
# - set .kube/config in k8s-master
########################################################################
# from https://10.0.0.10/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/ubuntu/.kube
# vi /home/ubuntu/.kube/config
sudo chown -Rf ubuntu:ubuntu /home/ubuntu

or

sudo mkdir /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown -Rf ubuntu:ubuntu /home/ubuntu

echo "" >> /home/ubuntu/.bash_profile
echo "alias ll='ls -al'" >> /home/ubuntu/.bash_profile
echo "alias k='kubectl --kubeconfig ~/.kube/config'" >> /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile





