#!/usr/bin/env bash

#set -x

echo "## [ Make an jenkins env ] #############################"
#DOCKER_ID=doohee323
#DOCKER_PASSWD=
sudo chown -Rf vagrant:vagrant /var/run/docker.sock

docker image build -t myjenkins .
docker image ls

# public image on docker hub
JENKINS_IMG=myjenkins
BRANCH=latest
docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
docker tag ${JENKINS_IMG}:${BRANCH} ${DOCKER_ID}/${JENKINS_IMG}:${BRANCH}
docker push ${DOCKER_ID}/${JENKINS_IMG}:${BRANCH}

echo "## [ Make a slave env ] #############################"
JENKINS_SLAVE_IMG=jenkins-slave
BRANCH=latest
mkdir /home/vagrant/jenkins-slave
cat <<EOF | sudo tee /home/vagrant/jenkins-slave/Dockerfile
FROM jenkins/jnlp-slave
ENTRYPOINT ["jenkins-slave"]
EOF

sudo chown -Rf vagrant:vagrant /home/vagrant/jenkins-slave
cd /home/vagrant/jenkins-slave
docker image build -t ${JENKINS_SLAVE_IMG} .
docker tag ${JENKINS_SLAVE_IMG}:${BRANCH} ${DOCKER_ID}/${JENKINS_SLAVE_IMG}:${BRANCH}
docker push ${DOCKER_ID}/${JENKINS_SLAVE_IMG}:${BRANCH}

echo "################################################"

#vi jenkins.yaml
#...
#    spec:
#      containers:
#        - name: jenkins
#          image: doohee323/myjenkins:latest

kubectl apply -f jenkins.yaml

echo "curl http://192.168.1.10:31000 in k8s-master"
echo "curl http://localhost:31000 in host"

