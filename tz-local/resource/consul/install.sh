#!/usr/bin/env bash

#set -x
shopt -s expand_aliases
alias k='kubectl'

helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/consul

k create namespace consul
helm install consul hashicorp/consul -f /vagrant/tz-local/resource/consul/values.yaml -n consul
#helm uninstall consul -n consul
#helm install consul hashicorp/consul --set global.name=consul

# to NodePort
k patch svc consul-consul-ui --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31699}]' -n consul

k port-forward service/consul-consul-server 8500:8500 -n consul &

#k delete -f /vagrant/tz-local/resource/consul/consul.yaml -n consul
#k apply -f /vagrant/tz-local/resource/consul/consul.yaml -n consul

#k get pod/tz-consul-deployment-78597cd9c5-vsbg4 -o yaml > a.yaml

echo '
##[ Consul ]##########################################################
- url: http://dooheehong323:31699

# install for test on host
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
unzip consul_1.8.4_linux_amd64.zip
mv consul /usr/local/bin/

export CONSUL_HTTP_ADDR="localhost:8500"
#export CONSUL_HTTP_ADDR="dooheehong323:8500"
consul members
curl http://localhost:8500/v1/status/leader
#curl http://dooheehong323:8500/v1/status/leader

consul kv put hello world
consul kv put redis/config/connections 5
consul kv get redis/config/connections
consul kv get -recurse redis/config

consul watch -type=key -key=redis/config/connections ./my-key-handler.sh
#consul watch -type=keyprefix -prefix=redis/config/ ./my-key-handler.sh
vi my-key-handler.sh
#!/bin/bash
while read line
do
    echo $line >> dump.txt
done

consul kv put redis/config/connections 5
vi dump.txt
{"Key":"redis/config/connections","CreateIndex":510,"ModifyIndex":510,"LockIndex":0,"Flags":0,"Value":"NQ==","Session":""}
echo "NQ==" | base64 --decode

consul watch -type=event -name=web-deploy ./my-key-handler.sh -web-deploy
consul event -name=web-deploy 1609030
[{"ID":"b3abd566-f0c9-ce2d-1359-b855fd9050eb","Name":"web-deploy","Payload":"MTYwOTAzMA==","NodeFilter":"","ServiceFilter":"","TagFilter":"","Version":1,"LTime":3}]
echo "MTYwOTAzMA==" | base64 --decode

#######################################################################
' >> /vagrant/info
cat /vagrant/info


exit 0

cat <<EOF | sudo tee /etc/systemd/system/consulw.service
[Unit]
Description="HashiCorp Consul watch"
Requires=network-online.target
After=network-online.target

[Service]
User=vagrant
Group=vagrant
Type=forking
ProtectSystem=full
ExecStart=/usr/bin/consul watch -type=event -name=web-deploy /home/vagrant/my-key-handler.sh -web-deploy
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

vi my-key-watch.sh
#!/bin/bash
/usr/bin/consul watch -type=event -name=web-deploy /home/vagrant/my-key-handler.sh -web-deploy &

[Unit]
Description=Apache Spark Master and Slave Servers

[Service]
User=root
Type=oneshot
ExecStart=/home/vagrant/my-key-watch.sh
ExecStop=/bin/kill --signal HUP
RemainAfterExit=true
StandardOutput=journal

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload
sudo systemctl enable consulw
service consulw start


