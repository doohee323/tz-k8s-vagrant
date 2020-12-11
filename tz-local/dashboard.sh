#!/usr/bin/env bash

shopt -s expand_aliases

#set -x
alias k='kubectl --kubeconfig ~/.kube/config'

cd /vagrant

## install dashboard
#kubectl create namespace kube-system
k apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
k get svc -n kubernetes-dashboard

## make token
k create serviceaccount admin-user
k create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=default:admin-user

## export crt
grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
cat kubecfg.crt

## export key
grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
cat kubecfg.key

## make a certificate
echo "type secretPassword as default."
openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-admin" \
-passout pass:secretPassword

## copy files to /vagrant
sudo cp -Rf /etc/kubernetes/pki/ca.crt /vagrant/ca.crt
sudo cp -Rf kubecfg.p12 /vagrant/kubecfg.p12

echo "check url: "
k cluster-info
echo "Kubernetes master is running at https://192.168.1.10:6443"
echo "KubeDNS is running at https://192.168.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy"

echo "get dashboard url: "
echo "https://192.168.1.10:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
#https://dooheehong323:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

echo "get token: "
k describe secret $(k -n kube-system get secret | grep admin-user | awk '{print $1}') -n kube-system

echo "add certificate in macOS to fix certi error!!:"

exit 0

cat << EOF
ex) for macOS

cd tz-k8s-vagrant
security add-trusted-cert \
  -r trustRoot \
  -k "/Users/dhong/Library/Keychains/login.keychain" \
  ./ca.crt    # under tz-k8s-vagrant folder

security import \
  ./kubecfg.p12 \
  -k "/Users/dhong/Library/Keychains/login.keychain" \
  -P secretPassword

EOF

