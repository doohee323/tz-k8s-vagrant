#!/usr/bin/env bash

shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

k create namespace kafka

k delete -f /vagrant/tz-local/resource/kafka/storage-local.yaml -n kafka
k apply -f /vagrant/tz-local/resource/kafka/storage-local.yaml -n kafka
k get pv -n kafka
k get pvc -n kafka

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
#helm uninstall bonah -n kafka
#helm install bonah bitnami/kafka -n kafka
ZOOKEEPER_SERVICE_NAME=bonah-zookeeper
helm install kafka bitnami/kafka
  --set zookeeper.enabled=false
  --set replicaCount=3
  --set externalZookeeper.servers=ZOOKEEPER_SERVICE_NAME -n kafka

helm install zookeeper bitnami/zookeeper \
  --set replicaCount=3 \
  --set auth.enabled=false \
  --set allowAnonymousLogin=true

sleep 30

k get all -n kafka

#k taint nodes --all node-role.kubernetes.io/master-
#k get statefulset.apps/bonah-kafka -n kafka -o yaml > /vagrant/tz-local/resource/kafka/bonah-kafka.yaml
#k delete statefulset.apps/bonah-kafka -n kafka
#sudo sed -i "s|8Gi|300Mi|g" /vagrant/tz-local/resource/kafka/bonah-kafka.yaml
#k get statefulset.apps/bonah-zookeeper -n kafka -o yaml > /vagrant/tz-local/resource/kafka/bonah-zookeeper.yaml
#k delete statefulset.apps/bonah-zookeeper -n kafka

# run client
k run bonah-kafka-client --restart='Never' --image docker.io/bitnami/kafka:2.6.0-debian-10-r0 -n kafka --command -- sleep infinity

echo '
##[ Kafka ]##########################################################

# make a topic
k exec --tty -i bonah-kafka-client -n kafka -- bash
$ kafka-topics.sh --create --bootstrap-server bonah-kafka-0.bonah-kafka-headless.kafka.svc.cluster.local:9092 \
--topic quickstart-events

# make a producer
$ kafka-console-producer.sh \
--broker-list bonah-kafka-0.bonah-kafka-headless.kafka.svc.cluster.local:9092 \
--topic quickstart-events

# make a consumer
k exec --tty -i bonah-kafka-client -n kafka -- bash
$ kafka-console-consumer.sh \
--bootstrap-server bonah-kafka.kafka.svc.cluster.local:9092 \
--from-beginning \
--topic quickstart-events

#######################################################################
' >> /vagrant/info
cat /vagrant/info

ZOOKEEPER_SERVICE_NAME=bonah-zookeeper
helm upgrade bonah bitnami/kafka \
  --set zookeeper.enabled=false \
  --set replicaCount=2 \
  --set externalZookeeper.servers=${ZOOKEEPER_SERVICE_NAME} -n kafka

#helm upgrade zookeeper bitnami/zookeeper \
#  --set replicaCount=5 \
#  --set auth.enabled=false \
#  --set allowAnonymousLogin=true -n kafka
