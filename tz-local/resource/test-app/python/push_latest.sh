#!/usr/bin/env bash

set -x

USERNAME=$1
PASSWD=$2

cd /var/jenkins_home/workspace/tz-py-crawler_push

if [[ ! -d 'projects/tz-py-crawler' ]]; then
  mkdir projects
  cd projects
  git clone https://github.com/doohee323/tz-py-crawler.git
fi

cd /var/jenkins_home/workspace/tz-py-crawler_push/projects/tz-py-crawler

#vi Dockerfile
#CMD [ "python", "/code/youtube/youtube/server.py" ]
docker build -t tz-py-crawler .
docker login -u="$USERNAME" -p="$PASSWD"
docker tag tz-py-crawler:latest doohee323/tz-py-crawler:latest
docker push doohee323/tz-py-crawler:latest

exit 0

