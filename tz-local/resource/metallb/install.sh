#!/usr/bin/env bash

#https://yunhochung.medium.com/k8s-%EB%8C%80%EC%89%AC%EB%B3%B4%EB%93%9C-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%99%B8%EB%B6%80-%EC%A0%91%EC%86%8D-%EA%B8%B0%EB%8A%A5-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0-22ed1cd0999f

shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

k delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
k delete -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
k apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
k apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml

# On first install only
k create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

k get pods -n metallb-system

k delete -f /vagrant/tz-local/resource/metallb/layer2-config.yaml
k apply -f /vagrant/tz-local/resource/metallb/layer2-config.yaml

k logs -l component=speaker -n metallb-system

exit 0