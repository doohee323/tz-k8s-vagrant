#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/postgres/install.sh
cd /vagrant/tz-local/resource/postgres/bastion

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

NS=devops-dev

cd /Volumes/workspace/tz/tz-k8s-vagrant/resources
kubectl exec -n devops-dev -it bastion -- mkdir -p /root/.k8s
kubectl cp project devops-dev/bastion:/root/.k8s
kubectl exec -n devops-dev -it bastion -- mkdir -p /root/.kube
kubectl cp kubeconfig_topzone-k8s devops-dev/bastion:/root/.kube/config
kubectl exec -n devops-dev -it bastion -- mkdir -p /root/.k8s
kubectl cp .bashrc devops-dev/bastion:/root/.bashrc
kubectl exec -n devops-dev -it bastion -- bash -c 'cd /root && rm -Rf /vagrant && rm -Rf /root/tz-k8s-vagrant && git clone https://github.com/doohee323/tz-k8s-vagrant.git && cd / && ln -s /root/tz-k8s-vagrant /vagrant && git checkout -b mlflow_hyper-v origin/mlflow_hyper-v'

######################################################################
TAG=latest
SNAPSHOT_IMG=devops-utils2
DOCKER_ID=doohee323
#docker push doohee323/devops-utils2:latest

# --no-cache
docker image build -t ${SNAPSHOT_IMG} . -f Dockerfile
docker tag ${SNAPSHOT_IMG}:latest ${DOCKER_ID}/${SNAPSHOT_IMG}:${TAG}
docker push ${DOCKER_ID}/${SNAPSHOT_IMG}:${TAG}

