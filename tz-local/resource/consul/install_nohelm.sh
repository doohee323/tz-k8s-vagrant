#!/usr/bin/env bash

# https://caylent.com/hashicorp-vault-on-kubernetes
#https://github.com/kainlite/vault-consul-tls/tree/master/consul
#https://medium.com/swlh/consul-in-kubernetes-pushing-to-production-223506bbe8db
git clone https://github.com/liejuntao001/consul-k8s-production.git

#set -x
shopt -s expand_aliases
alias k='kubectl'

# install for test on host
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
unzip consul_1.8.4_linux_amd64.zip
sudo mv consul /usr/local/bin/
rm consul_1.8.4_linux_amd64.zip

mkdir -p /vagrant/tz-local/resource/consul
cd /vagrant/tz-local/resource/consul

#Creating Certificates for Hashicorp Consul and Vault
consul tls ca create
consul tls cert create -server -additional-dnsname server.dc1.cluster.local
consul tls cert create -client
mkdir certs
mv *.pem certs

cd production/consul

#Hashicorp Consul
#Create secret for the gossip protocol
export GOSSIP_ENCRYPTION_KEY=$(consul keygen)
kubectl delete namespace consul
#Step 1 bootstrap Consul cluster without ACL
kubectl apply -f consul_namespace.yml
kubectl apply -f consul_service.yml
kubectl apply -f consul_serviceaccount.yml
kubectl -n consul create configmap consul --from-file=config.json=config/01_no_acl_config.json -o yaml --dry-run

kubectl apply -f 01consul_statefulset_noacl.yml