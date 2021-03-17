#!/usr/bin/env bash

### https://lejewk.github.io/vault-get-started/
### https://www.udemy.com/course/hashicorp-vault/learn/lecture/17017040#overview
### https://github.com/btkrausen/hashicorp

#set -x
shopt -s expand_aliases
alias k='kubectl'

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault

k create namespace vault
#helm uninstall vault -n vault
helm install vault hashicorp/vault -f /vagrant/tz-local/resource/vault/values.yaml -n vault
k get all -n vault

# to NodePort
k patch svc vault-standby --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31700}]' -n vault

#k port-forward vault-0 8200:8200

k get pods -l app.kubernetes.io/name=vault -n vault

# vault operator init
# vault operator init -key-shares=3 -key-threshold=2
k -n vault exec -ti vault-0 -- vault operator init
#Unseal Key 1: tziIFhisqHbhPMAyWmZ1EF8dCdBazAirTKPqoSEQRnE5
#Unseal Key 2: 2OBomu+0eEug197BA+X/Gj6bO4LLyhogycJqob6LMywk
#Unseal Key 3: XW0lD/jSmzB6kEQEXGpWKY1GGSEb3TVtcKkQhGfFGQ17
#Unseal Key 4: 8X4geWBLDsykoNAG9e2Xkp6cHZPng3LlGdwS5395hrfJ
#Unseal Key 5: miXWXx5llHptPwf7sI2gLdkK06FZ085bJ25eYTJFk24I
#
#Initial Root Token: s.n0VkXLpWp165y2SzBp4X3KWr

# vault operator unseal
k -n vault exec -ti vault-0 -- vault operator unseal # ... Unseal Key 1
k -n vault exec -ti vault-0 -- vault operator unseal # ... Unseal Key 2,3,4,5

k -n vault exec -ti vault-1 -- vault operator unseal # ... Unseal Key 1
k -n vault exec -ti vault-1 -- vault operator unseal # ... Unseal Key 2,3,4,5

k -n vault get pods -l app.kubernetes.io/name=vault

#curl http://dooheehong323:31700/ui/vault/secrets
#vault login s.qBPblA0U9Bzmhgr8eRnukSqR

VAULT_VERSION="1.3.1"
curl -sO https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo mv vault /usr/local/bin/
vault --version

vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

echo '
##[ Vault ]##########################################################

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

vault secrets list -detailed

vault kv list kv
vault kv put kv/my-secret my-value=yea
vault kv get kv/my-secret

vault kv put kv/tz-vault tz-value=yes
vault kv get kv/tz-vault

vault kv delete kv/tz-vault

vault kv metadata get kv/tz-vault
vault kv metadata delete kv/tz-vault


# aws key
vault secrets enable aws

vault write aws/config/root \
access_key=AKIAW354R7YB6TQ7LZVA \
secret_key=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 \
region=us-west-1


#vault secrets enable -path=kv kv

# macos
brew tap hashicorp/tap
brew install hashicorp/tap/vault
export VAULT_ADDR=http://dooheehong323:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR
vault secrets list -detailed

vault audit enable file file_path=/home/vagrant/tmp/a.log

# path ex)
secrets
  apps
    app1_web
    app1_demon
  common
    api_key

#######################################################################
' >> /vagrant/info
cat /vagrant/info

exit 0


# https://blog.medinvention.dev/vault-consul-kubernetes-deployment/
# https://github.com/mmohamed/vault-kubernetes
# https://luniverse.io/vault-service-1/?lang=ko

##1- build cfssl
wget https://dl.google.com/go/go1.16.2.linux-amd64.tar.gz
tar xvfz go1.16.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.16.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

sudo apt-get update
sudo apt install build-essential -y
git clone https://github.com/cloudflare/cfssl.git
cd cfssl
make

sudo cp bin/cfssl /usr/sbin
sudo cp bin/cfssljson /usr/sbin

#2- Consul deployment :

# install for test on host
mkdir sample && cd sample
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
sudo apt-get install -y unzip jq
unzip consul_1.8.4_linux_amd64.zip
sudo mv consul /usr/local/bin/
cd ..
rm -Rf sample

# Generate CA and sign request for Consul
cd /vagrant/tz-local/resource/vault/nohelm2

cfssl gencert -initca consul/ca/ca-csr.json | cfssljson -bare ca
# Generate SSL certificates for Consul
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=consul/ca/ca-config.json \
-profile=default \
consul/ca/consul-csr.json | cfssljson -bare consul
# Perpare a GOSSIP key for Consul members communication encryptation
GOSSIP_ENCRYPTION_KEY=$(consul keygen)

#2. Create secret with Gossip key and public/private keys
#k create namespace consul
k delete secret consul -n consul
k -n consul create secret generic consul \
--from-literal=key="${GOSSIP_ENCRYPTION_KEY}" \
--from-file=ca.pem \
--from-file=consul.pem \
--from-file=consul-key.pem
k get secret consul -n consul

#3. Deploy 3 Consul members (Statefulset)
#kubectl delete -f consul/service.yaml
#kubectl delete -f consul/rbac.yaml
kubectl delete -f consul/config.yaml
#kubectl delete -f consul/consul.yaml

#kubectl apply -f consul/service.yaml
#kubectl apply -f consul/rbac.yaml
kubectl apply -f consul/config.yaml
#kubectl apply -f consul/consul.yaml

#4. Prepare SSL certificates for Consul client, it will be used by vault consul client (sidecar).
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=consul/ca/ca-config.json \
-profile=default \
consul/ca/consul-csr.json | cfssljson -bare client-vault

#5. Create secret for Consul client (like members)
k -n consul create secret generic client-vault \
--from-literal=key="${GOSSIP_ENCRYPTION_KEY}" \
--from-file=ca.pem \
--from-file=client-vault.pem \
--from-file=client-vault-key.pem

#3- Vault deployment :
kubectl apply -f vault/service.yaml
kubectl apply -f vault/config.yaml
kubectl apply -f vault/vault.yaml

#5- UI:
kubectl apply -f ingress.yaml
#k -n consul patch svc consul-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31699}]'
#k -n consul patch svc vault-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31700}]'

#6- Vault Injector deployment
kubectl apply -f vault-injector/service.yaml
kubectl apply -f vault-injector/rbac.yaml
kubectl apply -f vault-injector/deployment.yaml
kubectl apply -f vault-injector/webhook.yaml # webhook must be created after deployment


