#!/usr/bin/env bash

# https://caylent.com/hashicorp-vault-on-kubernetes
#https://github.com/kainlite/vault-consul-tls/tree/master/consul
#https://medium.com/swlh/consul-in-kubernetes-pushing-to-production-223506bbe8db

#set -x
shopt -s expand_aliases
alias k='kubectl'

# install for test on host
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
sudo apt-get install -y unzip jq
unzip consul_1.8.4_linux_amd64.zip
sudo mv consul /usr/local/bin/
rm consul_1.8.4_linux_amd64.zip

mkdir -p /vagrant/tz-local/resource/consul4
cd /vagrant/tz-local/resource/consul4

git clone https://github.com/liejuntao001/consul-k8s-production.git

#Creating Certificates for Hashicorp Consul and Vault
consul tls ca create
consul tls cert create -server -additional-dnsname server.dc1.cluster.local
consul tls cert create -client
mkdir certs
mv *.pem certs

#Hashicorp Consul
#Create secret for the gossip protocol
export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

cd consul-k8s-production

#Step 1 bootstrap Consul cluster without ACL
k create namespace consul
kubectl apply -f consul/consul_service.yml
kubectl apply -f consul/consul_serviceaccount.yml
kubectl -n consul create configmap consul \
  --from-file=config.json=consul/config/01_no_acl_config.json -o yaml --dry-run=client
kubectl apply -f consul/01consul_statefulset_noacl.yml

#Step 2 Enable ACL without enforcing it
kubectl -n consul create configmap consul --from-file=config.json=consul/config/02_acl_allow_config.json -o yaml --dry-run=client
kubectl apply -f consul/02consul_statefulset_acl_allow.yml
consul acl bootstrap


