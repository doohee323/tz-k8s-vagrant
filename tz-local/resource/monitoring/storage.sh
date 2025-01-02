#!/usr/bin/env bash

# https://rtfm.co.ua/en/grafana-loki-architecture-and-running-in-kubernetes-with-aws-s3-storage-and-boltdb-shipper/
# https://medium.com/techlogs/grafana-loki-with-aws-s3-backend-through-irsa-in-aws-kubernetes-cluster-93577dc482a
# https://grafana.com/docs/loki/latest/configuration/examples/#3-s3-without-credentials-snippetyaml

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/monitoring/s3.sh
cd /vagrant/tz-local/resource/monitoring

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

k8s_project=$(prop 'project' 'project')
k8s_domain=$(prop 'project' 'domain')
admin_password=$(prop 'project' 'admin_password')
basic_password=$(prop 'project' 'basic_password')
grafana_goauth2_client_id=$(prop 'project' 'grafana_goauth2_client_id')
grafana_goauth2_client_secret=$(prop 'project' 'grafana_goauth2_client_secret')
smtp_password=$(prop 'project' 'smtp_password')
STACK_VERSION=44.3.0
NS=monitoring

cp -Rf loki_storage.yaml loki_storage.yaml_bak
sed -i "s/k8s_project/${k8s_project}/g" loki_storage.yaml_bak

loki_storage=$(cat loki_storage.yaml_bak | base64 -w0)
cp loki_storage-secret.yaml loki_storage-secret.yaml_bak
sed -i "s|LOKI_ENCODE|${loki_storage}|g" loki_storage-secret.yaml_bak
kubectl -n ${NS} apply -f loki_storage-secret.yaml_bak
kubectl rollout restart statefulset.apps/loki -n ${NS}

# retention
# https://grafana.com/docs/loki/latest/operations/storage/retention/