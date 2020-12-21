#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

sudo mkdir -p /vagrant/data
sudo chmod -Rf 777 /vagrant/data

cd /vagrant/projects/tz-py-crawler

k delete -f tz-py-crawler.yaml
k delete -f tz-py-crawler-pv.yaml

k apply -f tz-py-crawler-pv.yaml
#k get pv
#k get pvc

k apply -f tz-py-crawler.yaml

sleep 30

k get all

curl -d "watch_ids=ioNng23DkIM" -X POST http://localhost:30007/crawl
#curl -d "watch_ids=ioNng23DkIM" -X POST http://localhost:8000/crawl
#curl -d "watch_ids=ioNng23DkIM" -X POST http://localhost:8088/crawl

exit 0

python /code/youtube/server.py -p 8088

k create deployment tz-py-crawler --image=doohee323/tz-py-crawler:latest
#k create deployment tz-py-crawler --image=doohee323/tz-py-crawler:debug3
#k expose rc tz-py-crawler --port=8000 --target-port=8000

#k exec -it pod/tz-py-crawler-95cd4c99b-lz47d bash
#k exec -it deployment.apps/tz-py-crawler bash
#k -v=9 exec -it pod/tz-py-crawler-6cc76cdbc9-2fpfx -- sh
#k exec -it pod/kibana-kibana-86cb487f94-6krfm -- sh
#/usr/bin/python3 /code/youtube/cli.py -l /mnt/list.txt

k exec -it pod/elasticsearch-master-0 -- sh -c "/usr/bin/touch /tmp/.es_start_file"

k get deployment tz-py-crawler -o yaml > tz-py-crawler.yaml
#k delete deployment.apps/tz-py-crawler
#docker rmi doohee323/tz-py-crawler:debug1

