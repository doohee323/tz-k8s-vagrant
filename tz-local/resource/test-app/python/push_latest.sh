#!/usr/bin/env bash

set -x

USERNAME=$1
PASSWD=$2

cd /var/jenkins_home/workspace/tz-py-crawler_push
#cd /vagrant/projects/tz-py-crawler

if [[ ! -d 'projects/tz-py-crawler' ]]; then
  mkdir projects
  cd projects
  git clone https://github.com/doohee323/tz-py-crawler.git
fi

cd /var/jenkins_home/workspace/tz-py-crawler_push/projects/tz-py-crawler

#vi Dockerfile
#CMD [ "python", "/code/youtube/youtube/server.py" ]
docker login -u="$USERNAME" -p="$PASSWD"

docker rmi tz-py-crawler
docker build -t tz-py-crawler .
docker image ls
docker tag tz-py-crawler:latest doohee323/tz-py-crawler:latest
docker push doohee323/tz-py-crawler:latest

exit 0

k delete -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_cronJob.yaml
k apply -f /vagrant/tz-local/resource/test-app/python/tz-py-crawler_cronJob.yaml

