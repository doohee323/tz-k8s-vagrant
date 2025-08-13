#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/metrics-server/install.sh
cd /vagrant/tz-local/resource/metrics-server

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_domain=$(prop 'project' 'domain') #
export project=$(prop 'project' 'project')
export admin_password=$(prop 'project' 'admin_password')
NS=default

kubectl get apiservice | grep metrics

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system \
  --set args="{--kubelet-preferred-address-types=InternalIP,--kubelet-use-node-status-port}" \
  --set resources.requests.cpu=50m --set resources.requests.memory=64Mi \
  --set args="{--kubelet-preferred-address-types=InternalIP,--kubelet-use-node-status-port,--kubelet-insecure-tls}"


kubectl -n kube-system get pods -l k8s-app=metrics-server
kubectl -n kube-system logs deploy/metrics-server
kubectl top nodes
kubectl top pods -A

## drillquiz Deployment 예시
#resources:
#  requests:
#    cpu: "200m"
#    memory: "256Mi"
#  limits:
#    cpu: "500m"
#    memory: "512Mi"
#kubectl rollout restart deploy/drillquiz -n devops
#kubectl get hpa -n devops drillquiz-ha -o wide
#kubectl describe hpa -n devops drillquiz-ha
