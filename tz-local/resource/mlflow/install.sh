#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/mlflow/install.sh
cd /vagrant/tz-local/resource/mlflow

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_project=$(prop 'project' 'project')
export admin_password=$(prop 'project' 'admin_password')
NS=devops-dev

helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update

#S3 (Minio) and PostgreSQL DB Configuration on Helm Upgrade Command Example
helm upgrade --install mlflow community-charts/mlflow \
  --namespace ${NS} \
  --set backendStore.databaseMigration=true \
  --set backendStore.postgres.enabled=true \
  --set backendStore.postgres.host=devops-postgres-postgresql.devops-dev.svc.cluster.local \
  --set backendStore.postgres.port=5432 \
  --set backendStore.postgres.database=mlflow \
  --set backendStore.postgres.user=admin \
  --set backendStore.postgres.password='DevOps!323' \
  --set artifactRoot.s3.enabled=true \
  --set artifactRoot.s3.bucket=mlflow \
  --set artifactRoot.s3.awsAccessKeyId=${k8s_project} \
  --set artifactRoot.s3.awsSecretAccessKey=${admin_password} \
  --set extraEnvVars.MLFLOW_S3_ENDPOINT_URL=http://minio.devops.svc.cluster.local:9000 \
  --set serviceMonitor.enabled=true

#CREATE DATABASE mlflow OWNER admin;
#POSTGRES_USER=admin
#POSTGRES_PASSWORD=DevOps!323
#POSTGRES_HOST=devops-postgres-postgresql.devops-dev.svc.cluster.local
#POSTGRES_PORT=5432

#1. Get the application URL by running these commands:
#  export POD_NAME=$(kubectl get pods --namespace devops-dev -l "app.kubernetes.io/name=mlflow,app.kubernetes.io/instance=mlflow" -o jsonpath="{.items[0].metadata.name}")
#  export CONTAINER_PORT=$(kubectl get pod --namespace devops-dev $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
#  echo "Visit http://127.0.0.1:8080 to use your application"
#  kubectl --namespace devops-dev port-forward $POD_NAME 8080:$CONTAINER_PORT