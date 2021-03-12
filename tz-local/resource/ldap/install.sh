#!/usr/bin/env bash

### https://rancher.com/docs/rancher/v2.x/en/admin-settings/authentication/openldap/

#set -x
shopt -s expand_aliases
alias k='kubectl'

helm repo add stable https://charts.helm.sh/stable
helm search repo stable | grep ldap

k create namespace openldap
helm install openldap stable/openldap -n openldap
#helm uninstall openldap -n openldap
k get all -n openldap

# to NodePort
k patch svc openldap --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31701}]' -n openldap

echo '
##[ Openldap ]##########################################################

curl http://dooheehong323:31701
admin / 

#######################################################################
' >> /vagrant/info
cat /vagrant/info

exit 0

