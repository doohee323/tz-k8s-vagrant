#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/minio/install.sh
cd /vagrant/tz-local/resource/minio

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_domain=$(prop 'project' 'domain')
export project=$(prop 'project' 'project')
export admin_password=$(prop 'project' 'admin_password')
NS=devops

helm repo add minio https://charts.min.io/
helm upgrade --install minio minio/minio \
  --set accessKey=${project} \
  --set secretKey=${admin_password} \
  --set persistence.storageClass=standard \
  --set persistence.size=10Gi
  -n ${NS}

cp -Rf minio-ingress.yaml minio-ingress.yaml_bak
sed -ie "s/k8s_project/${k8s_project}/g" minio-ingress.yaml_bak
sed -ie "s/k8s_domain/${k8s_domain}/g" minio-ingress.yaml_bak
#kubectl delete -f minio-ingress.yaml_bak -n minio
kubectl apply -f minio-ingress.yaml_bak -n ${NS}
