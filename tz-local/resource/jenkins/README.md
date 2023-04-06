# tz-jenkins

#1) private image on docker hub
#kubectl create secret docker-registry regcred \
#  --docker-server=https://index.docker.io/v1/   \
#  --docker-username=doohee323   \
#  --docker-password=xxxxxx   \
#  --docker-email=doohee323@gmail.com -n jenkins
#
#vi jenkins.yaml
#...
#    spec:
#      imagePullSecrets:
#        - name: regcred
#      containers:
#        - name: jenkins
#          image: doohee323/myjenkins:latest
#          env:

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

 - get jenkins url
   in Workloads
   => http://192.168.0.127:31000/

 - install jenkins plugins
   http://192.168.0.127:31000/pluginManager/available
   install "Matrix Authorization Strategy"
   install "Kubernetes"
   https://plugins.jenkins.io/kubernetes/

 - setting kubernetes plugin
   http://192.168.0.127:31000/configureClouds/
   $> kubectl cluster-info
   Kubernetes URL: https://192.168.0.127:6443
    * kubectl config view --minify | grep server
   Disable https certificate check: check
   Kubernetes Namespace: default
   Credentials: Secret file
        file: ~/.kube/config
        ID: kubeconfig
        Description: kubeconfig

   kubectl get svc | grep jenkins
    NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                          AGE
    jenkins      NodePort    10.103.95.248   <none>        8080:31000/TCP,50000:30263/TCP   17m
   Jenkins URL: http://192.168.0.185:31000

   Pod Templates: slave1
       Containers: slave1
       Docker image: doohee323/jenkins-slave

 - make a job
   job name: slave1
   build > execute shell: echo "i am slave1"; sleep 60
```

