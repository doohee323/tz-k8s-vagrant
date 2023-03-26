# tz-k8s-vagrant

## -. Prep. in MacOS
```
    virtualbox
    vagrant
    ansible
        brew install ansible
```

## -. Run VMs with k8s 
``` 
    vagrant up
``` 

## -. ssh into nodes  
### checking k8s nodes status
``` 
    vagrant ssh kube-master
    kubectl get nodes
```

### kube-node1
``` 
    vagrant ssh kube-node1
``` 

## -. install kubectl in macbook
### cf) https://kubernetes.io/docs/tasks/tools/install-kubectl/
``` 
    brew install kubectl
    mkdir -p ~/.kube
    cp tz-k8s-vagrant/config ~/.kube/config
    kubectl get nodes
```

## -. destroy VMs  
``` 
    vagrant destroy -f
``` 

