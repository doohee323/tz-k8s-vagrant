#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

cd /vagrant

## install dashboard
k apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml

k get svc kubernetes-dashboard -n kubernetes-dashboard -o yaml > /vagrant/tz-local/resource/dashboard/kubernetes-dashboard.yaml

k patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":32699}]' -n kubernetes-dashboard
k get svc -n kubernetes-dashboard

## make a admin
k apply -f /vagrant/tz-local/dashboard/dashboard-admin.yaml

echo "get dashboard url: "
k cluster-info
#Kubernetes control plane is running at https://192.168.1.10:6443
#KubeDNS is running at https://192.168.1.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#echo "https://192.168.0.143:32699/"

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
#sudo cp -Rf kubecfg.p12 /vagrant/kubecfg.p12

sleep 30

k get all -n kubernetes-dashboard

echo "get token: "
TOKEN=`k -n kube-system describe secret $(k -n kube-system get secret | grep admin-user | awk '{print $1}')  | awk '$1=="token:"{print $2}'`
echo $TOKEN

echo '
##[ Dashboard ]##########################################################
- Url: https://192.168.1.10:32699/
- Token: TOKEN

# add certificate in macOS to fix certi error,
# or Click a blank section of the denial page on chrome. Using your keyboard, type "thisisunsafe".

cd /Volumes/sambashare/tz-k8s-vagrant  # shared folder
security add-trusted-cert \
  -r trustRoot \
  -k "/Users/dhong/Library/Keychains/login.keychain" \
  ./ca.crt    # under tz-k8s-vagrant folder

security import \
  ./kubecfg.p12 \
  -k "/Users/dhong/Library/Keychains/login.keychain" \
  -P secretPassword

#######################################################################
' >> /vagrant/info
sudo sed -i "s|TOKEN|${TOKEN}|g" /vagrant/info
cat /vagrant/info

exit 0
