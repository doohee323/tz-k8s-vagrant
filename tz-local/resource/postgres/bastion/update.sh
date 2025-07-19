#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/postgres/install.sh
cd /vagrant/tz-local/resource/postgres/bastion

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

k8s_project=$(prop 'project' 'project')
NS=devops-dev

# 1. make ubuntu pod as bastion
kubectl -n devops-dev apply -f ubuntu.yaml

apt-get update -y
apt-get install -y vim curl wget jq unzip netcat apt-transport-https gnupg2 redis-tools postgresql-client

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install --update

curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 && \
    chmod +x aws-iam-authenticator && \
    mv aws-iam-authenticator /usr/local/bin

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl && \
    chmod 777 kubectl && \
    mv kubectl /usr/bin/kubectl

# 2. upload aws, k8s credentials
kubectl -n devops-dev cp /root/.k8s devops-dev/bastion:/root/.k8s
kubectl -n devops-dev cp /root/.kube devops-dev/bastion:/root/.kube
kubectl -n devops-dev cp /root/.ssh devops-dev/bastion:/root/.ssh

# 3. run ddl from bastion
#POSTGRES_HOST=$(kubectl -n devops-dev get svc devops-postgres-postgresql | tail -n 1 | awk '{print $4}')
POSTGRES_HOST=devops-postgres-postgresql.devops-dev.svc.cluster.local
echo ${POSTGRES_HOST}
POSTGRES_PORT=5432
POSTGRES_ROOT_PASSWORD=$(kubectl -n devops-dev get secret devops-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode; echo)
echo $POSTGRES_ROOT_PASSWORD
psql --host ${POSTGRES_HOST} -U admin -d drillquiz -p $POSTGRES_PORT

