#!/usr/bin/env bash

#set -x

echo "## [ Buil an app ] #############################"
cd /vagrant/scripts/jenkins
kubectl --kubeconfig ~/.kube/config apply -f jenkins.yaml

########################################################################
# - get jenkins url
########################################################################
# in Workloads
# => http://192.168.1.10:31756/

########################################################################
# - install jenkins plugins
########################################################################
# http://192.168.1.10:31756/pluginManager/available
# install "Kubernetes plugin"
# https://plugins.jenkins.io/kubernetes/

########################################################################
# - setting kubernetes plugin
########################################################################
# http://192.168.1.10:31756/configureClouds/
# kubectl cluster-info
# Kubernetes Url: https://192.168.1.10
#  $> kubectl config view
# Disable https certificate check: check
# Kubernetes Namespace: default
# Credentials: Jenkins
#      Username: doohee323
#      Password: xxx    -> https://github.com/settings/tokens
#      ID: GitHub
#
# kubectl get svc | grep jenkins
#NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                          AGE
#jenkins      NodePort    10.103.95.248   <none>        8080:31000/TCP,50000:30263/TCP   17m
# Jenkins URL: http://10.103.95.248:8080

# Pod Templates: slave1
#     Containers: slave1
#     Docker image: doohee323/jenkins-slave

########################################################################
# - make a job
########################################################################
# job name: slave1
# build > execute shell: echo "i am slave1"; sleep 60




