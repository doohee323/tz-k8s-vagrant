#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/minio/install.sh
cd /vagrant/tz-local/resource/minio

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_domain=$(prop 'project' 'domain') #
export project=$(prop 'project' 'project')
export admin_password=$(prop 'project' 'admin_password')
NS=devops

helm repo add minio https://charts.min.io/
#helm show values minio minio/minio> values.yaml
#kubectl cp values.yaml devops-dev/bastion:/vagrant/tz-local/resource/minio
#--reuse-values
#helm uninstall minio -n ${NS}
helm upgrade --install minio minio/minio \
  --namespace ${NS} \
  --set accessKey=${project} \
  --set secretKey=${admin_password} \
  --set persistence.storageClass=nfs-client \
  --set persistence.size=5Gi \
  --set resources.requests.memory=1Gi \
  --set replicas=3

#To access MinIO from localhost, run the below commands:
#  1. export POD_NAME=$(kubectl get pods --namespace devops -l "release=minio" -o jsonpath="{.items[0].metadata.name}")
#  2. kubectl port-forward $POD_NAME 9000 --namespace devops
#Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/
#You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:
#  1. Download the MinIO mc client - https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart
#  2. export MC_HOST_minio-local=http://$(kubectl get secret --namespace devops minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace devops minio -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000
#  3. mc ls minio-local

cp -Rf minio-ingress.yaml minio-ingress.yaml_bak
sed -ie "s/k8s_project/${k8s_project}/g" minio-ingress.yaml_bak
sed -ie "s/k8s_domain/${k8s_domain}/g" minio-ingress.yaml_bak
#kubectl delete -f minio-ingress.yaml_bak -n minio
kubectl apply -f minio-ingress.yaml_bak -n ${NS}

#https://minio.new-nation.church


