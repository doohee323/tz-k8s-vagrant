#!/usr/bin/env bash

#set -x
shopt -s expand_aliases

alias k='kubectl --kubeconfig ~/.kube/config'

TZ_PROJECT=tz-aws-terraform
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

cd /vagrant/${TZ_PROJECT}
master_ip=`terraform output | grep -A 2 "public_ip" | head -n 1 | awk '{print $3}'`
export master_ip=`echo $master_ip | sed -e 's/\"//g;s/ //;s/,//'`
private_ip=`terraform output | grep -A 2 "private_ip" | head -n 1 | awk '{print $3}'`
export private_ip=`echo $private_ip | sed -e 's/\"//g;s/ //;s/,//'`

echo '
# jenkins
sudo iptables -A PREROUTING -t nat -p tcp  -d PUBLIC_IP  --dport 31000 -j DNAT --to PRIVATE_IP:31000
sudo iptables -A FORWARD -p tcp --dport 31000 -d PRIVATE_IP -j ACCEPT
' > iptable.sh
sudo sed -i "s|PUBLIC_IP|${master_ip}|g" iptable.sh
sudo sed -i "s|PRIVATE_IP|${private_ip}|g" iptable.sh
bash iptable.sh
rm -Rf iptable.sh

sleep 30

echo '
##[ Jenkins ]##########################################################
- jenkins url: http://MASTER_IP:31000
- build a simple jenkins project
  read jenkins/README.md
- build a java jenkins project
  read jenkins/java/README.md
#######################################################################
' >> /home/vagrant/info
sudo sed -i "s|MASTER_IP|${master_ip}|g" /home/vagrant/info
cat /home/vagrant/info
