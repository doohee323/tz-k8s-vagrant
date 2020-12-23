#!/usr/bin/env bash

set -x

/usr/bin/rsync -i doohee323 -avzh /mnt/result/ dhong@192.168.0.199:/Volumes/workspace/etc/tz-k8s-elk/data/

exit 0