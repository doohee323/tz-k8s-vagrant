# tz-jenkins

#1) private image on docker hub
#kubectl create secret docker-registry regcred \
#  --docker-server=https://index.docker.io/v1/   \
#  --docker-username=doohee323   \
#  --docker-password=   \
#  --docker-email=doohee323@gmail.com
#
#vi jenkins.yaml
#...
#    spec:
#      containers:
#        - name: jenkins
#          image: myjenkins:latest
#        imagePullSecrets:
#        - name: regcred

#2) public image on docker hub
#DOCKER_ID=doohee323
#DOCKER_PASSWD=
#APP=myjenkins
#BRANCH=latest
#docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
#docker tag ${APP}:latest ${DOCKER_ID}/${APP}:${BRANCH}
#docker push ${DOCKER_ID}/${APP}:${BRANCH}
#vi jenkins.yaml
#...
#    spec:
#      containers:
#        - name: jenkins
#          image: doohee323/myjenkins:latest

###################################################
## install jenkins
###################################################
```
DOCKER_ID=doohee323
DOCKER_PASSWD=

bash install.sh

```

###################################################
## build a simple jenkins project
###################################################
```
bash build.sh

```

###################################################
## build a java jenkins project
###################################################
```
vi scripts/jenkins/java/README.md

```
