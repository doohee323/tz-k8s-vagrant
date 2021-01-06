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
su - ubuntu
curl --insecure -sfL https://10.0.0.10/v3/import/x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

or

wget https://10.0.0.10/v3/import/x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml --no-check-certificate
kubectl apply -f x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml --kubeconfig=kube_config_cluster.yml

########################################################################
# - set .kube/config
########################################################################
# from https://10.0.0.10/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/ubuntu/.kube
# vi /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo "" >> /home/ubuntu/.bash_profile
echo "alias ll='ls -al'" >> /home/ubuntu/.bash_profile
echo "alias kk='kubectl --kubeconfig ~/.kube/config'" >> /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile





