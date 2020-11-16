# tz-k8s-vagrant

## -. Prep. in MacOS
```
    virtualbox
    vagrant
```

## -. Run VMs with k8s 
``` 
    vagrant up
``` 

## -. ssh into nodes  
### checking k8s nodes status
``` 
    vagrant ssh k8s-master
    kubectl get nodes
```

### node-1
``` 
    vagrant ssh node-1
``` 

## -. install kubectl in macbook
### cf) https://kubernetes.io/docs/tasks/tools/install-kubectl/
``` 
    brew install kubectl
    mkdir -p ~/.kube
    cp tz-k8s-vagrant/config ~/.kube
    kubectl get nodes
```

## -. destroy VMs  
``` 
    vagrant destroy -f
``` 

