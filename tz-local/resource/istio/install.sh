#!/usr/bin/env bash

# https://lcc3108.github.io/articles/2020-12/certmanager
# https://istio.io/v1.4/docs/tasks/traffic-management/ingress/ingress-certmgr/
# https://prune998.medium.com/istio-1-1-7-lets-encrypt-working-9100cea9f503

source /root/.bashrc
#bash /vagrant/tz-local/resource/istio/install.sh
cd /vagrant/tz-local/resource/istio

#alias k="kubectl -n mc20-dev"

tz_project=topzone-k8s
tz_domain=drillquiz.com

NS=istio-system

curl -sL https://istio.io/downloadIstioctl | sh -
export PATH=$HOME/.istioctl/bin:$PATH
istioctl version
# istioctl operator remove -y  # Not needed in newer versions
kubectl delete ns istio-operator
kubectl delete ns istio-system

kubectl create ns istio-system

kubectl apply -f 1-istio-init.yaml
kubectl apply -f 2-istio-tz.yaml
kubectl apply -f 3-kiali-secret.yaml
kubectl apply -f 4-1.auth.yaml
kubectl replace -f 4-label-default-namespace.yaml

istioctl install --set values.defaultRevision=default

curl -Lo kiali.yaml https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/kiali.yaml
kubectl -n istio-system apply -f kiali.yaml
kubectl -n istio-system apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/grafana.yaml
kubectl -n istio-system apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/prometheus.yaml
kubectl -n istio-system apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/jaeger.yaml

kubectl get pod -n istio-system

sleep 120

kubectl -n default delete -f sample/sample1.yaml
kubectl -n default apply -f sample/sample1.yaml

kubectl -n istio-system apply -f istio-ingress.yaml

kubectl -n istio-system create token kiali
#kubectl -n istio-system create token kiali-service-account


# add jaeger datasource in grafana
#HTTP
#  - URL: http://tracing.istio-system.svc.cluster.local:80/jaeger

exit 0

minio_access_key_id=$(prop 'credentials' 'minio_access_key_id')
minio_secret_access_key=$(prop 'credentials' 'minio_secret_access_key')
#export minio_access_key_id=$(awk -F\" "/AccessKeyId/ { print \$4 }" $HOME/.aws/${tz_project}-eks-cert-manager-route53)
#export minio_secret_access_key=$(awk -F\" "/SecretAccessKey/ { print \$4 }" $HOME/.aws/${tz_project}-eks-cert-manager-route53)
echo "minio_access_key_id: ${minio_access_key_id}"
echo "minio_secret_access_key: ${minio_secret_access_key}"

export minio_secret_access_key_base64=$(echo -n "$minio_secret_access_key" | base64)
echo ${minio_secret_access_key_base64}

cp letsencrypt-istio.yaml letsencrypt-istio.yaml_bak
sed -i "s|tz_domain|${tz_domain}|g" letsencrypt-istio.yaml_bak
sed -i "s|tz_project|${tz_project}|g" letsencrypt-istio.yaml_bak
sed -i "s|minio_access_key_id|${minio_access_key_id}|g" letsencrypt-istio.yaml_bak
sed -i "s|minio_secret_access_key_base64|${minio_secret_access_key_base64}|g" letsencrypt-istio.yaml_bak
kubectl delete -f letsencrypt-istio.yaml_bak -n istio-system
kubectl apply -f letsencrypt-istio.yaml_bak -n istio-system
kubectl describe clusterissuer letsencrypt-istio
kubectl describe certificate ingress-cert-istio -n istio-system

kubectl -n istio-system delete -f sample/sample2.yaml
kubectl -n istio-system apply -f sample/sample2.yaml


kubectl -n istio-system apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx1-cert-istio
spec:
  secretName: nginx1-cert-istio
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-istio
  commonName: nginx1.test8.drillquiz.com
  dnsNames:
    - nginx1.test1.drillquiz.com
EOF

kubectl create ns test1
kubectl -n test1 delete -f sample/sample1.yaml
kubectl -n test1 apply -f sample/sample1.yaml

kubectl -n mc20 delete -f sample/mc20.yaml
kubectl -n mc20 apply -f sample/mc20.yaml

