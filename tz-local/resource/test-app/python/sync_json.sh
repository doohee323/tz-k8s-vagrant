#!/usr/bin/env bash

#k delete -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_cronJob.yaml
#k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_cronJob.yaml
#k delete -f /vagrant/tz-local/resource/test-app/python/tz-py-syncJob.yaml
#k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-syncJob.yaml
#k exec -it pod/tz-py-crawler-job-1608708060-w7gj7 -- sh

#set -x

mkdir -p /root/.ssh

echo '
Host 192.168.0.199
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  IdentityFile /mnt/doohee323
' > /root/.ssh/config

rsync -avzh -e ssh /mnt/result/ dhong@192.168.0.199:/Volumes/workspace/etc/tz-k8s-elk/data/

exit 0