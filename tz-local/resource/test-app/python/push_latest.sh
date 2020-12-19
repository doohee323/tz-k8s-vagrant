#!/usr/bin/env bash

set -x

cd /vagrant/projects/tz-py-crawler


#vi Dockerfile
#CMD [ "python", "/code/youtube/youtube/server.py" ]
docker build -t tz-py-crawler .
docker login -u="$USERNAME" -p="$PASSWD"
docker tag tz-py-crawler:latest doohee323/tz-py-crawler:latest
docker push doohee323/tz-py-crawler:latest

exit 0

