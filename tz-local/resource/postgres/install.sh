#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/mysql/install.sh
cd /vagrant/tz-local/resource/mysql

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_project="topzone-k8s" # $(prop 'project' 'project')
export admin_password='DevOps!323'  #$(prop 'project' 'admin_password')
NS=devops-dev

#helm show values bitnami/postgresql > values.yaml
cp values.yaml values.yaml_bak
export admin_password="${admin_password}"
export my_database=drillquiz
sed -ie "s|admin_password|${admin_password}|g" values.yaml_bak
sed -ie "s|my_database|${my_database}|g" values.yaml_bak

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm uninstall devops-postgres -n ${NS}
#--reuse-values
helm upgrade --install devops-postgres bitnami/postgresql -n ${NS} -f values.yaml_bak

#To connect to your database from outside the cluster execute the following commands:
kubectl port-forward --namespace devops-dev svc/devops-postgres-postgresql 5432:5432 &
PGPASSWORD="$admin_password" psql --host 127.0.0.1 -U admin -d drillquiz -p 5432
