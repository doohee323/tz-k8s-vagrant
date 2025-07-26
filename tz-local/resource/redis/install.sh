#!/usr/bin/env bash

source /root/.bashrc
cd /vagrant/tz-local/resource/redis
#bash /vagrant/tz-local/resource/redis/install.sh

#set -x
shopt -s expand_aliases

k8s_project=$(prop 'project' 'project')
NS=devops

alias k="kubectl --kubeconfig ~/.kube/config"

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

NAME=drillquiz
#helm uninstall redis-cluster-${NAME} -n ${NS}
helm upgrade --debug --install --reuse-values redis-cluster-${NAME} \
  --set cluster.replicaCount=1 \
  --set auth.enabled=false \
  --set securityContext.enabled=true \
  --set securityContext.fsGroup=2000 \
  --set securityContext.runAsUser=1000 \
  --set volumePermissions.enabled=true \
  --set master.persistence.enabled=true \
  --set replica.persistence.enabled=true \
  --set master.persistence.enabled=true \
  --set master.persistence.path=/data \
  --set master.persistence.size=1Gi \
  --set master.persistence.storageClass=local-path \
  --set replica.persistence.enabled=true \
  --set replica.persistence.path=/data \
  --set replica.persistence.size=1Gi \
  --set replica.persistence.storageClass=local-path \
bitnami/redis -n ${NS}

k patch StatefulSet/redis-cluster-${NAME}-master -p '{"spec": {"template": {"spec": {"nodeSelector": {"team": "drillquiz"}}}}}' -n ${NS}
k patch StatefulSet/redis-cluster-${NAME}-master -p '{"spec": {"template": {"spec": {"nodeSelector": {"environment": "dev"}}}}}' -n ${NS}
k patch StatefulSet/redis-cluster-${NAME}-replicas -p '{"spec": {"template": {"spec": {"nodeSelector": {"team": "drillquiz"}}}}}' -n ${NS}
k patch StatefulSet/redis-cluster-${NAME}-replicas -p '{"spec": {"template": {"spec": {"nodeSelector": {"environment": "dev"}}}}}' -n ${NS}
k patch StatefulSet/redis-cluster-${NAME}-replicas -p '{"spec": {"template": {"spec": {"replicas": 1}}}}' -n ${NS}
k patch svc redis-cluster-${NAME}-master -p '{"spec": {"type": "LoadBalancer"}}' -n ${NS}

k scale --replicas=0 StatefulSet redis-cluster-${NAME}-replicas -n ${NS}
k scale --replicas=1 StatefulSet redis-cluster-${NAME}-replicas -n ${NS}

sleep 240

#-. bastion에서 FLUSHDB 실행
kubectl -n extension-dev exec -it pod/drillquiz-bastion \
  -- redis-cli -h redis-cluster-${NAME}-master.${NS}.svc.cluster.local -p 6379 FLUSHDB

echo ${svc_elb}
echo securityGroup: ${securityGroup}

exit 0

nc -zv redis-cluster-${NAME}-master.${NS}.svc.cluster.local 6379
#sudo apt-get install redis-tools -y
redis-cli -h redis-cluster-${NAME}-master.${NS}.svc.cluster.local -p 6379
# set password
#redis-cli -h redis-cluster-${NAME}-master.${NS}.svc.cluster.local -p 6379 -a CONFIG set requirepass 1234qwer
#redis-cli -h redis-cluster-${NAME}-master.${NS}.svc.cluster.local -p 6379 -a 1234qwer CONFIG set requirepass 1111
#redis-cli -h redis-cluster-${NAME}-master.${NS}.svc.cluster.local -p 6379 -a 1111 CONFIG set requirepass 1234qwer

#export REDIS_PASSWORD=$(kubectl get secret --namespace ${NS} redis-cluster -o jsonpath="{.data.redis-password}" | base64 --decode)
#echo $REDIS_PASSWORD

