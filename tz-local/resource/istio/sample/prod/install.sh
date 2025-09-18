#!/usr/bin/env bash

source /root/.bashrc
#bash /vagrant/tz-local/resource/istio/sample/prod/install.sh
cd /vagrant/tz-local/resource/istio/sample/prod

#alias k="kubectl -n devops-dev"

tz_project=topzone-k8s
tz_domain=drillquiz.com

kubectl delete -f drillquiz.yaml -n devops
kubectl apply -f drillquiz.yaml -n devops

