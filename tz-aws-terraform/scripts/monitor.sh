#!/usr/bin/env bash

shopt -s expand_aliases

#set -x

TZ_PROJECT=tz-aws-terraform
alias k='kubectl --kubeconfig ~/.kube/config'

cd /home/vagrant

echo "## [ install helm ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

helm repo add stable https://charts.helm.sh/stable
helm repo update

k get po -n kube-system

#export HELM_HOST=localhost:44134

echo "## [ install prometheus ] #############################"
k create namespace monitoring
#k create serviceaccount tiller -n monitoring
#k create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=monitoring:tiller -n monitoring
#k create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=monitoring:tiller -n monitoring

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

k get svc -n monitoring
k patch svc monitor-prometheus-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":32449}]' -n monitoring
#k patch svc monitor-prometheus-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n monitoring

echo "sleep 30"
sleep 30

cd /vagrant/${TZ_PROJECT}
master_ip=`terraform output | grep -A 2 "public_ip" | head -n 1 | awk '{print $3}'`
export master_ip=`echo $master_ip | sed -e 's/\"//g;s/ //;s/,//'`
private_ip=`terraform output | grep -A 2 "private_ip" | head -n 1 | awk '{print $3}'`
export private_ip=`echo $private_ip | sed -e 's/\"//g;s/ //;s/,//'`

k get svc -n monitoring | grep monitor-prometheus-server
#monitor-prometheus-server          NodePort    10.105.94.92    <none>        80:32449/TCP             15m
echo "curl http://${private_ip}:32449 in master"

echo "## [ install grafana ] #############################"
helm search repo stable | grep grafana
helm install --generate-name stable/prometheus-operator -n monitoring
k get svc -n monitoring | grep grafana

k patch svc `k get svc -n monitoring | grep grafana | awk '{print $1}'` --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30912}]' -n monitoring
echo "curl http://${private_ip}:30912 in master"

echo '
# prometheus
sudo iptables -A PREROUTING -t nat -p tcp  -d PUBLIC_IP  --dport 32449 -j DNAT --to PRIVATE_IP:32449
sudo iptables -A FORWARD -p tcp --dport 32449 -d PRIVATE_IP -j ACCEPT

# grafana
sudo iptables -A PREROUTING -t nat -p tcp  -d PUBLIC_IP  --dport 30912 -j DNAT --to PRIVATE_IP:30912
sudo iptables -A FORWARD -p tcp --dport 30912 -d PRIVATE_IP -j ACCEPT
' > iptable.sh
sudo sed -i "s|PUBLIC_IP|${master_ip}|g" iptable.sh
sudo sed -i "s|PRIVATE_IP|${private_ip}|g" iptable.sh
bash iptable.sh
rm -Rf iptable.sh

sleep 30

echo '
##[ Monitoring ]##########################################################
- Prometheus: http://MASTER_IP:32449
- Grafana: http://MASTER_IP:30912
  admin / prom-operator
  import grafana ID from https://grafana.com/grafana/dashboards into your grafana!
#######################################################################
' >> /home/vagrant/info
sudo sed -i "s|MASTER_IP|${master_ip}|g" /home/vagrant/info
cat /home/vagrant/info

exit 0
