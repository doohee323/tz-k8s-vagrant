#!/usr/bin/env bash

#set -x
cd /vagrant/tz-local/resource
git clone https://github.com/doohee323/tz-py-crawler.git

cd tz-py-crawler
bash k8s.sh

echo '
##[ tz-py-crawler ]##########################################################
  Youtube crawler with scrapy and selenium(for lazy loading elements).
  curl -d "watch_id=ioNng23DkIM" -X POST http://localhost:30007/crawl
  csv files will be made under youtube folder or ~/tz-k8s-vagrant/data
#######################################################################
' >> /vagrant/info
cat /vagrant/info


