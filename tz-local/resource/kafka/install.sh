#!/usr/bin/env bash

k create namespace kafka
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install bonah bitnami/kafka -n kafka
#helm uninstall bonah -n kafka

# producer
k run bonah-kafka-client --restart='Never' --image docker.io/bitnami/kafka:2.6.0-debian-10-r0 --namespace kafka --command -- sleep infinity
sleep 20
k exec --tty -i bonah-kafka-client --namespace kafka -- bash

helm repo add stable https://charts.helm.sh/stable
helm repo update





curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm init --client-only --stable-repo-url https://charts.helm.sh/stable
helm init --stable-repo-url https://charts.helm.sh/stable --service-account tiller

helm repo rm stable
helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo rm incubator
helm repo add incubator https://charts.helm.sh/incubator


helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/



helm repo update
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

helm install --name my-kafka incubator/kafka

