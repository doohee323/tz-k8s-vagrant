#!/usr/bin/env bash

set -x

## install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl get svc -n kubernetes-dashboard

## make token
cat <<EOF | kubectl create -f -
 apiVersion: v1
 kind: ServiceAccount
 metadata:
   name: admin-user
   namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl create -f -
 apiVersion: rbac.authorization.k8s.io/v1
 kind: ClusterRoleBinding
 metadata:
   name: admin-user
 roleRef:
   apiGroup: rbac.authorization.k8s.io
   kind: ClusterRole
   name: cluster-admin
 subjects:
 - kind: ServiceAccount
   name: admin-user
   namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

## export crt
grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
cat kubecfg.crt

## export key
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
cat kubecfg.key

## make a certificate
openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-admin"
Enter Export Password: secretPassword
Verifying - Enter Export Password: secretPassword
ll kubecfg.p12
ll /etc/kubernetes/pki/ca.crt

## copy files to /vagrant
sudo cp /etc/kubernetes/pki/ca.crt /vagrant/ca.crt
sudo cp kubecfg.p12 /vagrant/kubecfg.p12

## add certificate to macOS
security add-trusted-cert \
  -r trustRoot \
  -k "$HOME/Library/Keychains/login.keychain" \
  ./ca.crt

security import \
  ./kubecfg.p12 \
  -k "$HOME/Library/Keychains/login.keychain" \
  -P secretPassword

## check url
kubectl cluster-info
Kubernetes master is running at https://192.168.1.10:6443
KubeDNS is running at https://192.168.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

## get dashboard url
https://192.168.1.10:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy
https://dooheehong323:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy


