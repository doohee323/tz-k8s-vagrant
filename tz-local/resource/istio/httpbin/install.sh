#!/usr/bin/env bash

# https://lcc3108.github.io/articles/2020-12/certmanager
# https://istio.io/v1.4/docs/tasks/traffic-management/ingress/ingress-certmgr/
# https://prune998.medium.com/istio-1-1-7-lets-encrypt-working-9100cea9f503

source /root/.bashrc
#bash /vagrant/tz-local/resource/istio/httpbin/install.sh
cd /vagrant/tz-local/resource/istio/httpbin

#alias k="kubectl -n mc20-dev"

tz_project=$(prop 'project' 'project')
tz_domain=$(prop 'project' 'domain')
HOSTZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name == '${tz_domain}.']" | grep '"Id"'  | awk '{print $2}' | sed 's/\"//g;s/,//' | cut -d'/' -f3)
echo $HOSTZONE_ID

NS=httpbin

kubectl create namespace $NS
kubectl label --overwrite namespace $NS istio-injection=enabled

kubectl apply -n $NS -f httpbin.yaml
kubectl apply -n $NS -f httpbin-gateway.yaml

export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
GATEWAY_URL=a42f6820b5321472dbd15a2864800566-379754940.ap-northeast-2.elb.amazonaws.com

curl -s -H 'X-Forwarded-For: 56.5.6.7, 72.9.5.6, 98.1.2.3' "$GATEWAY_URL/get?show_env=true"

curl -s -H 'X-Forwarded-For: 56.5.6.7, 72.9.5.6, 98.1.2.3' "$GATEWAY_URL/admin/healthcheck"

curl -v -s -H 'X-Forwarded-For: 56.5.6.7, 72.9.5.6, 98.1.2.3' https://api.drillquiz.com/account/healthcheck

kubectl -n istio-system apply -f alb.yaml
