#!/usr/bin/env bash

# install mongodb

source /root/.bashrc
#bash /vagrant/tz-local/resource/mongodb/run.sh
cd /vagrant/tz-local/resource/mongodb

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

k8s_project=$(prop 'project' 'project')
k8s_domain=$(prop 'project' 'domain')
admin_password=$(prop 'project' 'admin_password')
NS=airflow

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install tz-mongo bitnami/mongodb \
  --set auth.rootPassword=${admin_password} \
  --set auth.username=admin \
  --set auth.password=${admin_password} \
  --set auth.database=tz-mongo \
  -n ${NS}

#    tz-mongo-mongodb.airflow.svc.cluster.local
#To get the root password run:
#    export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace airflow tz-mongo-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)
#To get the password for "admin" run:
#    export MONGODB_PASSWORD=$(kubectl get secret --namespace airflow tz-mongo-mongodb -o jsonpath="{.data.mongodb-passwords}" | base64 -d | awk -F',' '{print $1}')
#To connect to your database, create a MongoDB&reg; client container:
#    kubectl run --namespace airflow tz-mongo-mongodb-client --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" --image docker.io/bitnami/mongodb:8.0.11-debian-12-r1 --command -- bash
#Then, run the following command:
#    mongosh admin --host "tz-mongo-mongodb" --authenticationDatabase admin -u $MONGODB_ROOT_USER -p $MONGODB_ROOT_PASSWORD
#To connect to your database from outside the cluster execute the following commands:
#    kubectl port-forward --namespace airflow svc/tz-mongo-mongodb 27017:27017 &
#    mongosh --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD

uri = "mongodb+srv://admin:${admin_password}@tz-mongo-mongodb.airflow.svc.cluster.local/?retryWrites=true&w=majority&appName=Cluster0"
MONGODB_ROOT_PASSWORD=${admin_password}
mongosh --host tz-mongo-mongodb.airflow.svc.cluster.local \
        --authenticationDatabase tz-mongo  \
        --username admin \
        --password $MONGODB_ROOT_PASSWORD

#apt update
#apt install -y gnupg curl
#curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
#echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" > /etc/apt/sources.list.d/mongodb-org-7.0.list
#apt update
#apt install -y mongodb-mongosh
