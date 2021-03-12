#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl'

export VAULT_ADDR=http://10.106.177.255:8200
#export VAULT_ADDR=http://dooheehong323:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

# set a secret engine
vault secrets list
vault secrets list -detailed
vault secrets enable -path=test1 kv
vault secrets enable -path=test1 -version=2 kv
vault secrets disable test1

# add a userpass
vault auth enable userpass
vault write auth/userpass/users/dewey password=22222 policies=tz-vault-policy1
vault delete auth/userpass/users/dewey
vault list auth/userpass/users
vault read auth/userpass/users/dewey

vault login -method=userpass username=dewey

# add a userpass
vault kv put skylines/apps/certs/database cert=@authorized_keys
vault secrets list -detailed | grep skylines
vault kv enable-versioning skylines
vault kv put skylines/apps/skyline_secret skyline=3333
vault kv get skylines/apps/skyline_secret
vault kv put skylines/apps/skyline_secret skyline=4444
vault kv get -version=1 skylines/apps/skyline_secret
vault kv delete skylines/apps/skyline_secret
vault kv undelete -versions=2 skylines/apps/skyline_secret
vault kv get skylines/apps/skyline_secret

exit 0

