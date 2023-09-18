#!/usr/bin/env bash

# https://guide.ncloud-docs.com/docs/k8s-k8suse-velero#3velero%EC%84%9C%EB%B2%84%EC%84%A4%EC%B9%98
# https://guide.ncloud-docs.com/docs/k8s-k8sexamples-velero

source /root/.bashrc
#bash /vagrant/tz-local/resource/velero/install.sh
cd /vagrant/tz-local/resource/velero

#set -x
shopt -s expand_aliases
alias k='kubectl -n consul'

eks_project=$(prop 'project' 'project')
AWS_REGION=$(prop 'config' 'region')
AWS_ACCESS_KEY_ID=$(prop 'credentials' 'aws_access_key_id')
AWS_SECRET_ACCESS_KEY=$(prop 'credentials' 'aws_secret_access_key')
basic_password=$(prop 'project' 'basic_password')
eks_domain=$(prop 'project' 'domain')
NS=devops

wget https://github.com/vmware-tanzu/velero/releases/download/v1.10.3/velero-v1.10.3-linux-amd64.tar.gz
tar -xvzf velero-v1.10.3-linux-amd64.tar.gz
sudo mv velero-v1.10.3-linux-amd64/velero /usr/local/bin/velero

#aws iam create-user --user-name ${eks_project}-velero
#aws iam put-user-policy \
#  --user-name ${eks_project}-velero \
#  --policy-name ${eks_project}-velero \
#  --policy-document file://velero-policy.json

#aws iam create-access-key --user-name ${eks_project}-velero

credentials_velero="~/.aws/credentials"
#[default]
#aws_access_key_id=<AWS_ACCESS_KEY_ID>
#aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>

BUCKET="devops-velero-${eks_project}"

kubectl create namespace velero

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm search repo vmware-tanzu/velero
helm uninstall velero -n velero
#helm show values vmware-tanzu/velero > values2.yaml
cp -Rf values.yaml values.yamll_bak
sed -i "s|EKS-CLUSTER|${eks_project}|g" values.yamll_bak
sed -i "s|AWS_REGION|${AWS_REGION}|g" values.yamll_bak
sed -i "s|AWS_ACCESS_KEY_ID|${AWS_ACCESS_KEY_ID}|g" values.yamll_bak
sed -i "s|AWS_SECRET_ACCESS_KEY|${AWS_SECRET_ACCESS_KEY}|g" values.yamll_bak

#helm template vmware-tanzu/velero -f values.yamll_bak -n velero
#--reuse-values
helm upgrade --debug --install velero vmware-tanzu/velero -f values.yamll_bak -n velero
#helm upgrade --debug --install velero vmware-tanzu/velero -f values.yamll_bak -n velero

kubectl get deployment/velero -n velero
#velero snapshot-location create default --provider aws/volume-snapshotter-plugin

VERSION="v1.9.3"
wget https://github.com/vmware-tanzu/velero/releases/download/${VERSION}/velero-${VERSION}-linux-amd64.tar.gz && \
  tar -xvzf velero-${VERSION}-linux-amd64.tar.gz && \
  mv velero-${VERSION}-linux-amd64/velero /usr/local/bin/velero && \
  rm -Rf velero-${VERSION}-linux-amd64.tar.gz && \
  rm -Rf velero-${VERSION}-linux-amd64

PROJECTS=(hypen hypen-dev)
#PROJECTS=(devops devops-dev mc20 mc20-dev hypen hypen-dev avatar avatar-dev default argocd consul monitoring vault elk)
#PROJECTS=(cert-manager external-secrets istio-operator istio-system jenkins kube-node-lease kube-public kube-system sonarqube)
for item in "${PROJECTS[@]}"; do
  echo "====================="
  echo ${item}
  if [[ "${item/*-dev/}" == "" ]]; then
    project=${item/-dev/}
    staging=dev
    echo "===================dev==${project} / ${namespaces}"
  else
    project=${item}
    project_stg=${item}-stg
    staging=prod
    echo "===================prod==${project} / ${namespaces}"
  fi
#  velero backup delete ${project}-${staging} -n velero

  velero backup create ${project}-${staging} --selector app=${project} --selector environment=${staging} -n velero
  velero schedule create ${item} --schedule="@every 1h" \
    --include-namespaces ${item} \
    --ttl 24h0m0s \
    -n velero

  if [ "${staging}" == "prod" ]; then
    velero backup create ${project_stg} --selector app=${project_stg} --selector environment=stg -n velero
    velero schedule create ${project_stg} --schedule="@every 1h" \
      --include-namespaces ${item} \
      --ttl 24h0m0s \
      -n velero
  fi
done

exit 0

kubectl apply -f nginx-example-dev.yaml -n nginx-example-dev

velero backup delete nginx-example-dev -n velero
velero backup create nginx-example-dev --selector app=nginx -n velero
#velero backup create nginx-example-dev --selector app=nginx --selector environment=dev -n velero
velero backup logs nginx-example-dev

kubectl delete -f nginx-example-dev.yaml
kubectl get deployments -n nginx-example-dev

velero restore create --from-backup nginx-example-dev -n velero
kubectl get deployments -n nginx-example-dev

kubectl get pvc -n nginx-example-dev
kubectl get pods -n nginx-example-dev

velero schedule create daily --schedule="@every 5m" \
  --include-namespaces nginx-example-dev \
  --ttl 24h0m0s \
  -n velero
 
velero get schedule -n velero

#kubectl delete namespace/velero clusterrolebinding/velero

kubectl -n mc20 delete deploy/mc20-mc20-version-main
velero restore create --from-backup mc20-20230621042708 -n velero