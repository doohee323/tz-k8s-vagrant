#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

#cd /vagrant/tz-local/resource/nexus
helm repo add jenkins https://charts.jenkins.io
helm search repo jenkins

helm list --all-namespaces -a

k patch svc jenkins --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31000}]' -n jenkins

echo '
##[ Jenkins ]##########################################################
  - ID: admin
  - Password:
    kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo
    kubectl exec -it service/jenkins-1617143063 -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo


#######################################################################
' >> /vagrant/info
cat /vagrant/info
