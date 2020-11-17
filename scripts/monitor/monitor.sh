#!/usr/bin/env bash

#set -x

echo "## [ install helm ] ######################################################
###https://twofootdog.tistory.com/17
###https://gruuuuu.github.io/cloud/monitoring-02/#


sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

helm repo add stable https://charts.helm.sh/stable
helm repo update

su - vagrant
kubectl get po -n kube-system

export HELM_HOST=localhost:44134

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
#kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#helm init

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

echo "################################################"

echo "## [ Monitoring with prometheus ] #############################"

# A bit confusing is the whole set of such Helm charts – there is a “simple” Prometheus chart, and  kube-prometheus, and prometheus-operator:
kubectl create namespace monitoring
#helm del --purge monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-community
helm install my-prometheus-operator --namespace monitoring prometheus-community/kube-prometheus-stack

kubectl get svc -n kube-system
kubectl get all -n monitoring
echo "admin / prom-operator"
kubectl config view --minify

kubectl get service/my-prometheus-operator-kub-prometheus -n monitoring -o yaml > prometheus.yaml
sed -ie "s|ClusterIP|LoadBalancer|g" prometheus.yaml
kubectl apply -f prometheus.yaml

kubectl get service/my-prometheus-operator-grafana -n monitoring -o yaml > grafana.yaml
sed -ie "s|ClusterIP|LoadBalancer|g" grafana.yaml
kubectl apply -f grafana.yaml

#kubectl port-forward service/prometheus-service 8080:8080 -n monitoring

sleep 60

GRAFANA_LB=`kubectl get all -n monitoring | grep 'service/my-prometheus-operator-grafana' | awk '{print $3}'`
echo "GRAFANA_LB: http://$GRAFANA_LB"
echo "admin / prom-operator"
echo "################################################"

exit 0


kubectl apply -f prometheus-cluster-role.yaml
kubectl apply -f prometheus-config-map.yaml
kubectl apply -f prometheus-deployment.yaml
kubectl apply -f prometheus-node-exporter.yaml
kubectl apply -f prometheus-svc.yaml


echo "## [ Memory / CPU tunning ] ##################################################"
minikube addons list
#| metrics-server              | minikube | disabled     |
minikube addons enable metrics-server
# after 1~2 minutes
sleep 120

kubectl describe node minikube
kubectl get all -n kube-system
kubectl top pod
kubectl top node
echo "################################################"


