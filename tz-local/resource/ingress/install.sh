#!/usr/bin/env bash

#https://kubernetes.io/docs/concepts/services-networking/ingress/

shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

k apply -f wordpress-ingress.yaml -n wordpress

exit 0