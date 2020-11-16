# tz-k8s-vagrant

## -. Prep. in ubuntu
```
    sudo apt install virtualbox -y
    sudo apt install vagrant -y
    sudo wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.deb
    sudo dpkg –i vagrant_2.2.2_x86_64.deb
    vagrant ––version
    sudo mkdir ~/vagrant-ubuntu
    cd ~/vagrant-ubuntu
    sudo vagrant init bento/ubuntu-18.04
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

## destroy VMs  
``` 
    vagrant destroy -f
``` 

