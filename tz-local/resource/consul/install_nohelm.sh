#!/usr/bin/env bash

# https://blog.medinvention.dev/vault-consul-kubernetes-deployment/
# https://github.com/mmohamed/vault-kubernetes

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

# install for test on host
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
sudo apt-get install -y unzip jq
unzip consul_1.8.4_linux_amd64.zip
sudo mv consul /usr/local/bin/
rm -Rf consul_1.8.4_linux_amd64.zip

# Generate CA and sign request for Consul
cd /vagrant/tz-local/resource/consul/nohelm

cfssl gencert -initca consul/ca/ca-csr.json | cfssljson -bare ca
# Generate SSL certificates for Consul
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=ca/ca-config.json \
-profile=default \
ca/consul-csr.json | cfssljson -bare consul
# Perpare a GOSSIP key for Consul members communication encryptation
GOSSIP_ENCRYPTION_KEY=$(consul keygen)

#2. Create secret with Gossip key and public/private keys
k create namespace vault
k delete secret consul
k -n vault create secret generic consul \
--from-literal=key="${GOSSIP_ENCRYPTION_KEY}" \
--from-file=ca.pem \
--from-file=consul.pem \
--from-file=consul-key.pem
k get secret consul -n vault

#3. Deploy 3 Consul members (Statefulset)
kubectl delete -f consul/service.yaml
kubectl delete -f consul/rbac.yaml
kubectl delete -f consul/config.yaml
kubectl delete -f consul/consul.yaml

kubectl apply -f consul/service.yaml
kubectl apply -f consul/rbac.yaml
kubectl apply -f consul/config.yaml
kubectl apply -f consul/consul.yaml

#4. Prepare SSL certificates for Consul client, it will be used by vault consul client (sidecar).
cfssl gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=consul/ca/ca-config.json \
-profile=default \
consul/ca/consul-csr.json | cfssljson -bare client-vault

#5. Create secret for Consul client (like members)
k -n vault create secret generic client-vault \
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
#k -n vault patch svc consul-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31699}]'
#k -n vault patch svc vault-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31700}]'

#6- Vault Injector deployment
kubectl apply -f vault-injector/service.yaml
kubectl apply -f vault-injector/rbac.yaml
kubectl apply -f vault-injector/deployment.yaml
kubectl apply -f vault-injector/webhook.yaml # webhook must be created after deployment

#7- Sample deployment :
mkdir sample
cd sample
curl https://releases.hashicorp.com/vault/1.6.2/vault_1.6.2_linux_amd64.zip -o vault_1.6.2_linux_amd64.zip
unzip vault_1.6.2_linux_amd64.zip
chmod +x vault
sudo mv vault /usr/local/bin/

cd /vagrant/tz-local/resource/consul/nohelm
#http://dooheehong323:31699/ui/vault/nodes/vault-6db4484b8-wx4m4/service-instances
export VAULT_ADDR=http://172.16.84.186:8200
vault status

#7.1- Unseal
k get all -n vault
#pod/vault-6db4484b8-wx4m4
k -n vault exec -ti vault-6db4484b8-wx4m4 -- sh
export VAULT_ADDR=http://localhost:8200
vault operator init

#Unseal Key 1: y6DY7tv72f2OQ0nlvrbB90s8h5zrDu8jk5y9ruM7kRix
#Unseal Key 2: CPpP2zkuanKLQTLsaEE4nn7jjhO5YFRnkjjMSbCtvOYX
#Unseal Key 3: 8UDH3d4sTjeGagT2DiCAxvs2BB/TaB4QlXv3viFEfkSz
#Unseal Key 4: 9uM4CQc/M8iLs1r456FuYOyfsXwtwCObZtjg9y8+sOwl
#Unseal Key 5: q8oQEVyQclD7TZj5oCmJX3MpMx8mS2jbvMgayderjB0F
#
#Initial Root Token: s.IBa4LZiOSsP8wyhhe9YXQKAw

# vault operator unseal
vault operator unseal

vault login s.IBa4LZiOSsP8wyhhe9YXQKAw

#3. Create key/value for testing
vault secrets enable kv
vault kv put kv/myapp/config username="admin" password="hdh971097"

#4. Connect K8S to Vault
# Create the service account to access secret
kubectl apply -f myapp/service-account.yaml
# Enable kubernetes support
vault auth enable kubernetes
# Prepare kube api server data
export SECRET_NAME="$(kubectl -n vault get serviceaccount vault-auth  -o go-template='{{ (index .secrets 0).name }}')"
export TR_ACCOUNT_TOKEN="$(kubectl -n vault get secret ${SECRET_NAME} -o go-template='{{ .data.token }}' | base64 --decode)"
export K8S_API_SERVER="$(kubectl -n vault config view --raw -o go-template="{{ range .clusters }}{{ index .cluster \"server\" }}{{ end }}")"
export K8S_CACERT="$(kubectl -n vault config view --raw -o go-template="{{ range .clusters }}{{ index .cluster \"certificate-authority-data\" }}{{ end }}" | base64 --decode)"
# Send kube config to vault
vault write auth/kubernetes/config kubernetes_host="${K8S_API_SERVER}" kubernetes_ca_cert="${K8S_CACERT}" token_reviewer_jwt="${TR_ACCOUNT_TOKEN}"

#5. Create Vault policy and role for "myapp"
#myapp/policy.json
#path "kv/myapp/*" {
#  capabilities = ["read", "list"]
#}

#Create the application role
vault policy write myapp-ro myapp/policy.json
vault write auth/kubernetes/role/myapp-role bound_service_account_names=vault-auth bound_service_account_namespaces=vault policies=default,myapp-ro ttl=15m

#6. Deploy "myapp" for testing
#edit admin / password
#vi vault/myapp/deployment.yaml

kubectl apply -f myapp/deployment.yaml
export POD=$(kubectl -n vault get pods --selector=app=myapp --output=jsonpath={.items..metadata.name})
kubectl logs ${POD} myapp -n vault









