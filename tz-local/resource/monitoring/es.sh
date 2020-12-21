#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

## make storage folders
rm -Rf /vagrant/es/index1
rm -Rf /vagrant/es/index2
mkdir -p /vagrant/es/index1
mkdir -p /vagrant/es/index2

## clean objests
k delete -f /vagrant/tz-local/resource/monitoring/elastic-stack.yaml
k delete -f /vagrant/tz-local/resource/monitoring/fluentd-config.yaml

k delete pvc elasticsearch-logging-elasticsearch-logging-0 -n kube-system
k delete pvc elasticsearch-logging-elasticsearch-logging-1 -n kube-system

k delete -f /vagrant/tz-local/resource/monitoring/storage-local.yaml
#k delete pv es-pv -n kube-system
#k delete pv es-pv1 -n kube-system

## make es env.
k apply -f /vagrant/tz-local/resource/monitoring/storage-local.yaml
k apply -f /vagrant/tz-local/resource/monitoring/fluentd-config.yaml

k apply -f /vagrant/tz-local/resource/monitoring/elastic-stack.yaml

k get all -n kube-system

sleep 30

# if pvc issue occurs,
k get pvc -n kube-system
k get pvc elasticsearch-logging-elasticsearch-logging-1 -n kube-system -o json > /vagrant/tz-local/resource/monitoring/storage-pvc1.yaml
k delete -f /vagrant/tz-local/resource/monitoring/storage-pvc1.yaml
sudo sed -i "s|es-pv\"|es-pv1\"|g" /vagrant/tz-local/resource/monitoring/storage-pvc1.yaml
k apply -f /vagrant/tz-local/resource/monitoring/storage-pvc1.yaml
#k get pv -n kube-system

sleep 30

k get all -n kube-system

echo '
##[ ES ]##########################################################
- Url: http://192.168.1.10:30601
#######################################################################
' >> /vagrant/info
cat /vagrant/info

exit 0

