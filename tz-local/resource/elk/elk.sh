#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

rm -Rf /vagrant/es/index0
rm -Rf /vagrant/es/index1
rm -Rf /vagrant/es/index2
mkdir -p /vagrant/es/index0
mkdir -p /vagrant/es/index1
mkdir -p /vagrant/es/index2

helm repo add elastic https://helm.elastic.co
helm repo update
helm search hub elasticsearch
helm install elasticsearch elastic/elasticsearch
helm uninstall elasticsearch

k delete pvc elasticsearch-master-elasticsearch-master-0
k delete pvc elasticsearch-master-elasticsearch-master-1
k delete pvc elasticsearch-master-elasticsearch-master-2
k get pvc
k get pv

k delete -f /vagrant/tz-local/resource/elk/storage-local.yaml

## make es env.
k apply -f /vagrant/tz-local/resource/elk/storage-local.yaml

k get pvc elasticsearch-master-elasticsearch-master-0 -o json > /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-0.yaml
k delete -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-0.yaml
sudo sed -i "s|Filesystem\"|Filesystem\",\n\"storageClassName\": \"local-storage0\"|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-0.yaml
sudo sed -i "s|30Gi|2Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-0.yaml
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-0.yaml

k get pvc elasticsearch-master-elasticsearch-master-1 -o json > /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-1.yaml
k delete -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-1.yaml
sudo sed -i "s|Filesystem\"|Filesystem\",\n\"storageClassName\": \"local-storage1\"|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-1.yaml
sudo sed -i "s|30Gi|2Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-1.yaml
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-1.yaml

k get pvc elasticsearch-master-elasticsearch-master-2 -o json > /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-2.yaml
k delete -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-2.yaml
sudo sed -i "s|Filesystem\"|Filesystem\",\n\"storageClassName\": \"local-storage2\"|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-2.yaml
sudo sed -i "s|30Gi|2Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-2.yaml
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-elasticsearch-master-2.yaml

k get all

helm uninstall elasticsearch
helm install elasticsearch --version 7.8.0 elastic/elasticsearch

k get statefulset.apps/elasticsearch-master -o json > /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|Filesystem\"|Filesystem\",\n\"storageClassName\": \"local-storage0\"|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|30Gi|2Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|2Gi|2Gi|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
sudo sed -i "s|replicas\": 3|replicas\": 2|g" /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
k delete -f /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml
k apply -f /vagrant/tz-local/resource/elk/elasticsearch-master-statefulset.yaml

#k get pod/elasticsearch-master-0 -o json > /vagrant/tz-local/resource/elk/elasticsearch-master-0.yaml
k exec -it pod/elasticsearch-master-0 -- sh -c "/usr/bin/touch /tmp/.es_start_file"
k exec -it pod/elasticsearch-master-1 -- sh -c "/usr/bin/touch /tmp/.es_start_file"

#k port-forward svc/elasticsearch-master 31200:9200 &
curl http://localhost:31200/
curl http://192.168.1.10:31200

helm uninstall filebeat
helm install filebeat elastic/filebeat
curl http://localhost:31200/_cat/indices

helm uninstall kibana
helm install kibana --version 7.8.0 elastic/kibana
k port-forward svc/kibana-kibana 30601:5601 &
curl http://localhost:30601
curl http://192.168.1.10:30601

k get pod/kibana-kibana-86cb487f94-bwdpq -o json > /vagrant/tz-local/resource/elk/kibana-kibana-86cb487f94-bwdpq.yaml


echo '
##[ ES ]##########################################################
- Url: http://192.168.1.10:30601
#######################################################################
' >> /vagrant/info
cat /vagrant/info

exit 0

