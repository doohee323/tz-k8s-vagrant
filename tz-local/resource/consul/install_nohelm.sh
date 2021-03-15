#!/usr/bin/env bash

#https://github.com/mmohamed/vault-kubernetes
# https://blog.medinvention.dev/vault-consul-kubernetes-deployment/

##1- build cfssl
wget https://dl.google.com/go/go1.16.2.linux-amd64.tar.gz
tar xvfz go1.16.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

sudo apt install build-essential -y
git clone https://github.com/cloudflare/cfssl.git
cd cfssl
make

sudo cp bin/cfssl /usr/sbin
sudo cp cfssl/bin/cfssljson /usr/sbin

#2- Consul deployment :
# Generate CA and sign request for Consul



cfssl gencert -initca ca/ca-csr.json | cfssljson -bare ca
# Generate SSL certificates for Consul
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=ca/ca-config.json \
-profile=default \
ca/consul-csr.json | cfssljson -bare consul
# Perpare a GOSSIP key for Consul members communication encryptation
GOSSIP_ENCRYPTION_KEY=$(consul keygen)

