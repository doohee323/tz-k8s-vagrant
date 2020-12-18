#!/usr/bin/env bash

#set -x
shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

TZ_PROJECT=tz-local
cd /vagrant/${TZ_PROJECT}/resource/jenkins

echo "## [ Make an jenkins env ] #############################"
if [[ -f "/vagrant/${TZ_PROJECT}/resource/dockerhub" ]]; then
  export DOCKER_ID=`grep 'docker_id' /vagrant/${TZ_PROJECT}/resource/dockerhub | awk '{print $3}'`
  export DOCKER_PASSWD=`grep 'docker_passwd' /vagrant/${TZ_PROJECT}/resource/dockerhub | awk '{print $3}'`

  image_exists=`DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect ${DOCKER_ID}/myjenkins:latest`
  if [[ `echo $image_exists | wc | awk '{print $2}'` == 0 ]]; then
    echo "---------------------------------------------------------------------------------------"
    echo "Can't ${DOCKER_ID}/myjenkins:latest, so make and push my own jenkins image to Dockerhub."
    echo "---------------------------------------------------------------------------------------"
    docker image build -t myjenkins .
    docker image ls

    # public image on docker hub
    APP=myjenkins
    BRANCH=latest
    docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
    docker tag ${APP}:latest ${DOCKER_ID}/${APP}:${BRANCH}
    docker push ${DOCKER_ID}/${APP}:${BRANCH}
  fi
else
  DOCKER_ID='doohee323'
fi

cp -Rf jenkins.yaml jenkins_run.yaml
sudo sed -i "s|DOCKER_ID|${DOCKER_ID}|g" jenkins_run.yaml
k apply -f jenkins_run.yaml
sudo rm -Rf jenkins_run.yaml

sleep 60

echo '
##[ Jenkins ]##########################################################
- jenkins url: http://192.168.1.10:31000
- build a simple jenkins project
  read jenkins/README.md
- build a java jenkins project
  read test-app/java/README.md
#######################################################################
' >> /vagrant/info
cat /vagrant/info
