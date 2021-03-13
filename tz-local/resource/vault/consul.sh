#!/usr/bin/env bash

# https://learn.hashicorp.com/tutorials/vault/pki-engine

#set -x
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
vault -h

export VAULT_ADDR=http://10.106.177.255:8200
vault login s.qBPblA0U9Bzmhgr8eRnukSqR

export CONSUL_HTTP_ADDR="localhost:8500"
#export CONSUL_HTTP_ADDR="dooheehong323:8500"
consul members
consul acl bootstrap


exit 0


