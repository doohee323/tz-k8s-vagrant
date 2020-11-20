#!/usr/bin/env bash

#set -x

echo "## [ Buil an app ] #############################"

########################################################################
# - apply jenkins deployment and service
########################################################################
kubectl --kubeconfig ~/.kube/config apply -f jenkins_deployment.yaml
kubectl --kubeconfig ~/.kube/config apply -f jenkins_service.yaml

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
# Credentials: token-w5q54 / 42plh4bw97grt7xkj96qrjhd5ckqmjfdz66v77x6tt5jrlmwlw6kvg
# kubectl get svc
#NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                          AGE
#jenkins      NodePort    10.98.238.147   <none>        8080:31000/TCP,50000:32363/TCP   11h
#kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP                          11h
# Jenkins URL: http://10.98.238.147:8080

# Pod Templates: slave1
#     Containers: slave1
#     Docker image: doohee323/jenkins-slave

########################################################################
# - make a job
########################################################################
# job name: slave1
# build > execute shell: echo "i am slave1"; sleep 60




