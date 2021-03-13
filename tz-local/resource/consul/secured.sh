#!/usr/bin/env bash

# https://learn.hashicorp.com/tutorials/consul/kubernetes-secure-agents
# https://learn.hashicorp.com/tutorials/consul/access-control-setup-production#create-the-initial-bootstrap-token

#set -x
shopt -s expand_aliases
alias k='kubectl'


KEYGEN=$(consul keygen)
echo ${KEYGEN}
#u9FUbEiT3VySubWb8F2lPtFhTeq2CK6xWmDAw3d26t4
#k -n consul create secret generic consul-gossip-encryption-key --from-literal=key=ln9L+0LtZlyVCJD/POl+RxNbw3Q/cmmtoK8hpN1YmpI=
k -n consul delete secret consul-gossip-encryption-key
k -n consul create secret generic consul-gossip-encryption-key --from-literal=key=${KEYGEN}

#secret/consul-gossip-encryption-key created

# vi secured-values.yaml
#  gossipEncryption:
#    secretName: "consul-gossip-encryption-key"
#    secretKey: "key"

helm upgrade consul hashicorp/consul -f /vagrant/tz-local/resource/consul/secured-values.yaml -n consul --wait

# verify
#k -n consul port-forward consul-consul-server-0 8501:8501
k patch svc consul-consul-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31699}]' -n consul

#export CONSUL_HTTP_ADDR=https://127.0.0.1:8501
export CONSUL_HTTP_ADDR="dooheehong323:8500"
k -n consul get secret consul-consul-ca-cert -o jsonpath="{.data['tls\.crt']}" | base64 --decode > ca.pem
consul members -ca-file ca.pem

# Set an ACL token
consul debug -ca-file ca.pem


