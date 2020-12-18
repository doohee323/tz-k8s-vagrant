#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

TZ_PROJECT=tz-aws-terraform

cd /home/vagrant

echo "## [ install prometheus ] #############################"
k create namespace monitoring

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

helm upgrade -f volumeF.yaml monitor stable/prometheus -n monitoring

k get svc -n monitoring
k patch svc monitor-prometheus-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":32449}]' -n monitoring

cd /home/ubuntu/${TZ_PROJECT}
master_ip=`terraform output | grep -A 2 "public_ip" | head -n 1 | awk '{print $3}'`
export master_ip=`echo $master_ip | sed -e 's/\"//g;s/ //;s/,//'`
private_ip=`terraform output | grep -A 2 "private_ip" | head -n 1 | awk '{print $3}'`
export private_ip=`echo $private_ip | sed -e 's/\"//g;s/ //;s/,//'`

k get svc -n monitoring | grep monitor-prometheus-server
#monitor-prometheus-server          NodePort    10.105.94.92    <none>        80:32449/TCP             15m
echo "curl http://${private_ip}:32449 in master"

echo "## [ install grafana ] #############################"
helm repo add stable https://charts.helm.sh/stable
helm repo update

helm search repo stable | grep grafana
helm install --wait --timeout 30s --generate-name stable/prometheus-operator -n monitoring
#helm list -n monitoring
#helm delete prometheus-operator-1608326191 -n monitoring
k get svc -n monitoring | grep grafana

k patch svc `k get svc -n monitoring | grep grafana | awk '{print $1}'` --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30912}]' -n monitoring
echo "curl http://${private_ip}:30912 in master"

k get all -n monitoring

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
' >> /vagrant/info
sudo sed -i "s|MASTER_IP|${master_ip}|g" /vagrant/info
cat /vagrant/info

exit 0
