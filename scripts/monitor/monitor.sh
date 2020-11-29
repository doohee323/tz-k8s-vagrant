#!/usr/bin/env bash

#set -x

echo "" >> ~/.bashrc
echo "alias ll='ls -al'" >> ~/.bashrc
echo "alias k='kubectl --kubeconfig ~/.kube/config'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc

echo "## [ install helm ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh

helm repo add stable https://charts.helm.sh/stable
helm repo update

sudo cp -Rf /root/.kube /home/vagrant
sudo chown -Rf vagrant:vagrant /home/vagrant/.kube
kubectl get po -n kube-system

export HELM_HOST=localhost:44134

echo "## [ install prometheus ] #############################"
kubectl create namespace monitoring
#kubectl create serviceaccount tiller -n monitoring
#kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=monitoring:tiller -n monitoring
#kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=monitoring:tiller -n monitoring

helm search repo stable | grep prometheus
helm install monitor stable/prometheus -n monitoring

helm inspect values stable/prometheus

cat <<EOF > volumeF.yaml
alertmanager:
    persistentVolume:
        enabled: false
server:
    persistentVolume:
        enabled: false
pushgateway:
    persistentVolume:
        enabled: false
EOF

echo "sleep 30"
sleep 30

helm upgrade -f volumeF.yaml monitor stable/prometheus -n monitoring

kubectl get svc -n monitoring
kubectl patch svc monitor-prometheus-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":32449}]' -n monitoring
#kubectl patch svc monitor-prometheus-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n monitoring

echo "sleep 30"
sleep 30

kubectl get svc -n monitoring | grep monitor-prometheus-server
#monitor-prometheus-server          NodePort    10.105.94.92    <none>        80:32449/TCP             15m
echo "curl http://192.168.1.10:32449"

echo "## [ install grafana ] #############################"
helm search repo stable | grep grafana
helm install --generate-name stable/prometheus-operator -n monitoring
kubectl get svc -n monitoring | grep grafana

kubectl patch svc `kubectl get svc -n monitoring | grep grafana | awk '{print $1}'` --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30912}]' -n monitoring

echo "curl http://192.168.1.10:30912"
echo "admin / prom-operator"
echo "import grafana ID from https://grafana.com/grafana/dashboards into your grafana!"

exit 0
