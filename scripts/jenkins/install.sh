#!/usr/bin/env bash

#set -x

echo "## [ Make an jenkins env ] #############################"

docker image build -t myjenkins .

docker image ls

# public image on docker hub
APP=myjenkins
BRANCH=latest
docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
docker tag ${APP}:latest ${DOCKER_ID}/${APP}:${BRANCH}
docker push ${DOCKER_ID}/${APP}:${BRANCH}

#vi jenkins.yaml
#...
#    spec:
#      containers:
#        - name: jenkins
#          image: doohee323/myjenkins:latest

kubectl apply -f jenkins.yaml

echo "curl http://192.168.1.10:31000 in k8s-master"
echo "curl http://localhost:31000 in host"

echo "################################################"
