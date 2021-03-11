#!/usr/bin/env bash

### https://lejewk.github.io/vault-get-started/
### https://www.udemy.com/course/hashicorp-vault/learn/lecture/17017040#overview

#set -x
shopt -s expand_aliases
alias k='kubectl'

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault

k create namespace vault
helm uninstall vault -n vault
helm install vault hashicorp/vault -f /vagrant/tz-local/resource/vault/values.yaml -n vault
k get all -n vault

# to NodePort
k patch svc vault-standby --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31700}]' -n vault

#k port-forward vault-0 8200:8200

k get pods -l app.kubernetes.io/name=vault -n vault

# vault operator init
# vault operator init -key-shares=3 -key-threshold=2
k -n vault exec -ti vault-0 -- vault operator init

#Unseal Key 1: a/62Q/Q/eWuX3WlJVL7bNQkIm2Qr59eipOb5PkQmr+Xd
#Unseal Key 2: wLfzEwrLaCPYCnVCFvvqDPx1jPodKGRqNwhp57QCFlS5
#Unseal Key 3: Z/0/HAeLx6iSCPjOKP9C/YIfNlbxtzMK6pWBQUYioeK/
#Unseal Key 4: oisGOpvlF6NDpCPhBmRIkOWt6Pd46VD9Z7gkifSnq31X
#Unseal Key 5: qRe2t6aRlYP8gp60fJebvpeO1tqgSWqAgAJQzUaUNPe+
#
#Initial Root Token: s.qBPblA0U9Bzmhgr8eRnukSqR

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




cat <<EOF | sudo tee /etc/vault/config.hcl
disable_cache = true
disable_mlock = true
ui = true
api_addr         = "http://0.0.0.0:8200"
listener "tcp" {
   address          = "0.0.0.0:8200"
   tls_disable      = 1
}
storage "file" {
   path  = "/var/lib/vault/data"
}
max_lease_ttl         = "10h"
default_lease_ttl    = "10h"
cluster_name         = "vault"
raw_storage_endpoint     = true
disable_sealwrap     = true
disable_printable_check = true
EOF

# production ex)
cat <<EOF | sudo tee /etc/vault/config.hcl
storage "consul" {
    path = "vault"
    address = "localhost:8500"
}
listener "tcp" {
   address          = "0.0.0.0:8200"
   cluster_address  = "0.0.0.0:8201"
   tls_cert_file    = "/etc/certs/vault.crt"
   tls_cert_key     = "/etc/certs/vault.key"
}
seal "awskms" {
  region = "us-west-02"
  kms_key_id = "aaaaaaa"
}
api_addr            = "http://0.0.0.0:8200"
ui = true
cluster_name        = "tz-vault"
log_level           = "info"

disable_cache = true
disable_mlock = true
max_lease_ttl       = "10h"
default_lease_ttl   = "10h"
raw_storage_endpoint = true
disable_sealwrap     = true
disable_printable_check = true
EOF


kubectl create secret generic vault-storage-config \
    --from-file=/etc/vault/config.hcl


