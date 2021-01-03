#!/usr/bin/env bash

shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

k apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
k apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml

k get pods -n metallb-system
