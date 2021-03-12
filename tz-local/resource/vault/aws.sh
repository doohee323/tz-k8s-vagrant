#!/usr/bin/env bash

### https://lejewk.github.io/vault-get-started/

#set -x
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

# aws key
vault secrets enable aws
vault write aws/config/root \
access_key=AKIAW354R7YB6TQ7LZVA \
secret_key=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 \
region=us-west-1

exit 0

