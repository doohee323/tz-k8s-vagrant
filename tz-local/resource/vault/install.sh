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

