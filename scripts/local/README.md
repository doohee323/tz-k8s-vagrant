# tz-k8s-vagrant

## -. Prep. in MacOS
```
    virtualbox
    vagrant
```

## -. Run VMs with k8s 
``` 
    $> vagrant up
``` 

## -. ssh into nodes  
### checking k8s nodes status
``` 
    $> vagrant status
    k8s-master                running (virtualbox)
    node-1                    running (virtualbox)

    $> vagrant ssh k8s-master
    $> kubectl get nodes
```

### node-1
``` 
    $> vagrant ssh node-1
``` 

## -. install kubectl in macbook
### cf) https://kubernetes.io/docs/tasks/tools/install-kubectl/
``` 
    $> brew install kubectl
    $> mkdir -p ~/.kube
    $> cp tz-k8s-vagrant/config ~/.kube/config
    $> kubectl get nodes
```

## test apply
``` 
    root@k8s-master:/home/ubuntu# kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
    root@k8s-master:/home/ubuntu# kubectl get pods -o wide
    NAME                                   READY   STATUS    RESTARTS   AGE     IP              NODE     NOMINATED NODE   READINESS GATES
    kubernetes-bootcamp-57978f5f5d-wrrns   1/1     Running   0          3m32s   172.16.84.129   node-1   <none>           <none>
    root@k8s-master:/home/ubuntu# curl http://172.16.84.129:8080
    Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-57978f5f5d-wrrns | v=1
```

## -. destroy VMs  
``` 
    $> vagrant destroy -f
``` 

