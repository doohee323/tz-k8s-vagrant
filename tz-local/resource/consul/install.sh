#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl'

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/consul

helm install consul hashicorp/consul -f values.yaml
#helm uninstall consul hashicorp/consul
#helm install consul hashicorp/consul --set global.name=consul

# to NodePort
k patch svc consul-consul-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31699}]' -n default

kubectl port-forward service/consul-consul-server 8500:8500 &

k delete -f /vagrant/tz-local/resource/consul/consul.yaml
k apply -f /vagrant/tz-local/resource/consul/consul.yaml

#k get pod/tz-consul-deployment-78597cd9c5-vsbg4 -o yaml > a.yaml

echo '
##[ Consul ]##########################################################
- url: http://dooheehong323:31699

# install for test on host
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
unzip consul_1.8.4_linux_amd64.zip
mv consul /usr/local/bin/
export CONSUL_HTTP_ADDR="dooheehong323:8500"
consul kv put hello world

#######################################################################
' >> /vagrant/info
cat /vagrant/info

