#!/usr/bin/env bash

### https://www.vaultproject.io/api

#set -x
shopt -s expand_aliases
alias k='kubectl'

vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

vault policy list
vault policy read default

# add policy
echo '
path "skylines/vault/*" {
    capabilities = ["list", "read","update","delete","create"]
}
path "skylines/*" {
    capabilities = ["list", "read","update","delete","create"]
}
path "kv/tz-vault/*" {
    capabilities = ["list", "read","update","delete","create"]
}
' > policy1.hcl
vault policy write tz-vault-policy1 policy1.hcl

# add a new user
vault write auth/userpass/users/tz-vault \
password=11111 \
policies=tz-vault-policy1
#policies=tz-vault-policy1,skyline

vault login -method=userpass username=tz-vault
vault token lookup

echo '{
    "password": "11111"
}' > data.json

# login with http
curl \
    --request POST \
    --data @data.json \
    http://10.106.177.255:8200/v1/auth/userpass/login/tz-vault | jq

exit 0


