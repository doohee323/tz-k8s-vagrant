# tz-k8s-vagrant

It supports two version of k8s installation, shell and ansible. First need to copy proper Vagrantfile
to project root directory. 

## -. Refer to README.md for each version.
```
    scripts/shell/README.md
    scripts/ansible/README.md
```

## -. Copy Vagrantfile to project root directory.
```
    cp scripts/shell/Vagrantfile Vagrantfile
    or
    cp scripts/ansible/Vagrantfile Vagrantfile
    or
    cp scripts/monitor/Vagrantfile Vagrantfile
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
    cp tz-k8s-vagrant/config ~/.kube/config
    kubectl get nodes
```

## -. destroy VMs  
``` 
    vagrant destroy -f
``` 

