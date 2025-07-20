#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/mysql/install.sh
cd /vagrant/tz-local/resource/mysql

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_project=$(prop 'project' 'project')
export admin_password=#$(prop 'project' 'admin_password')
NS=devops-dev


helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
helm install mlflow community-charts/mlflow
helm install [RELEASE_NAME] community-charts/mlflow
