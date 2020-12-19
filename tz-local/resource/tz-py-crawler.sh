#!/usr/bin/env bash

#set -x
cd /vagrant/projects
git clone https://github.com/doohee323/tz-py-crawler.git

cd tz-py-crawler
git pull origin master
bash k8s.sh

echo '
##[ tz-py-crawler ]##########################################################
  Youtube crawler with scrapy and selenium(for lazy loading elements).
  curl -d "watch_id=ioNng23DkIM" -X POST http://localhost:30007/crawl
  csv files will be made under youtube folder or ~/tz-k8s-vagrant/data
#######################################################################
' >> /vagrant/info
cat /vagrant/info

#k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_autoscale.yaml
#k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_cronJob.yaml
