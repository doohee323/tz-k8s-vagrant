#!/usr/bin/env bash

#k delete -f /vagrant/tz-local/resource/test-app/python/tz-py-syncJob.yaml
#k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-syncJob.yaml
#k exec -it pod/tz-py-sync-job-1608709260-nkx46 -- sh

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

#ssh-copy-id -i /mnt/doohee323.pub dhong@192.168.0.199
rsync -avzh -e ssh /mnt/result/ dhong@192.168.0.199:/Volumes/workspace/etc/tz-k8s-elk/data/

exit 0