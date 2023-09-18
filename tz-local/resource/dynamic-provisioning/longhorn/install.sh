#!/usr/bin/env bash

#https://longhorn.io/docs/1.5.1/deploy/install/install-with-helm/

source /root/.bashrc
cd /vagrant/tz-local/resource/dynamic-provisioning/longhorn

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

helm repo add longhorn https://charts.longhorn.io
helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.5.1
kubectl get storageclass

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl get storageclass
kubectl --namespace longhorn-system get service longhorn-frontend
#kubectl --namespace longhorn-system port-forward --address 0.0.0.0 service/longhorn-frontend 5080:80

kubectl -n longhorn-system apply -f longhorn-ingress.yml

#USER=<USERNAME_HERE>; PASSWORD=<PASSWORD_HERE>; echo "${USER}:$(openssl passwd -stdin -apr1 <<< ${PASSWORD})" >> auth
kubectl -n longhorn-system create secret generic basic-auth --from-file=auth

exit 0