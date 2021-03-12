#!/usr/bin/env bash

### https://www.vaultproject.io/api

#set -x
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

vault kv list skylines/vault
vault kv get skylines/vault/course

vault kv list kv/tz-vault

echo '{
  "max_versions": 5,
  "cas_required": false,
  "delete_version_after": "3h25m19s"
}' > payload.json

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request POST \
    --data @payload.json \
    http://10.106.177.255:8200/v1/secret/config

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    http://10.106.177.255:8200/v1/secret/config

echo '{
  "options": {
    "cas": 0
  },
  "data": {
    "foo": "bar",
    "zip": "zap"
  }
}' > payload.json
curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request POST \
    --data @payload.json \
    http://10.106.177.255:8200/v1/secret/data/my-secret

echo '{
  "options": {
    "cas": 1
  },
  "data": {
    "foo": "bar11",
    "zip": "zap11"
  }
}' > payload.json
curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request POST \
    --data @payload.json \
    http://10.106.177.255:8200/v1/secret/data/my-secret

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    http://10.106.177.255:8200/v1/secret/data/my-secret?version=1

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request DELETE \
    http://10.106.177.255:8200/v1/secret/data/my-secret

echo '{
  "versions": [2]
}' > payload.json
curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request POST \
    --data @payload.json \
    http://10.106.177.255:8200/v1/secret/delete/my-secret

echo '{
  "versions": [2]
}' > payload.json
curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request POST \
    --data @payload.json \
    http://10.106.177.255:8200/v1/secret/undelete/my-secret

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    --request LIST \
    http://10.106.177.255:8200/v1/secret/metadata/my-secret

curl \
    --header "X-Vault-Token: s.qBPblA0U9Bzmhgr8eRnukSqR" \
    http://10.106.177.255:8200/v1/secret/metadata/my-secret

exit 0


