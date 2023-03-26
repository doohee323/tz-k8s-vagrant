#!/usr/bin/env bash

#set -x

cd /vagrant/kubespray
ansible all -i inventory/mycluster/inventory.ini -m ping

declare -a IPS=(192.168.1.10 192.168.1.12 192.168.1.13)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml

sudo cp -Rf /root/.kube /home/vagrant/
sudo chown -Rf vagrant:vagrant /home/vagrant/.kube

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
exec bash

kubectl get nodes
kubectl cluster-info

exit 0

#k delete -f /vagrant/tz-local/resource/standard-storage.yaml
k apply -f /vagrant/tz-local/resource/standard-storage.yaml
k patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

# nfs
# 1. with helm
#helm install my-release --set nfs.server=192.168.1.10 --set nfs.path=/srv/nfs/mydata stable/nfs-client-provisioner
# 2. with manual
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/static-nfs.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/serviceaccount.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/nfs.yaml
#k apply -f /vagrant/tz-local/resource/dynamic-provisioning/nfs/nfs-claim.yaml

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

sleep 10

helm repo add stable https://charts.helm.sh/stable
helm repo update

#k get po -n kube-system

sudo rm -Rf /vagrant/info

##################################################################
# call nfs dynamic-provisioning
##################################################################
bash /vagrant/tz-local/resource/dynamic-provisioning/nfs/install.sh

##################################################################
# call metallb
##################################################################
bash /vagrant/tz-local/resource/metallb/install.sh

##################################################################
# call dashboard install script
##################################################################
bash /vagrant/tz-local/resource/dashboard/install.sh

##################################################################
# call monitoring install script
##################################################################
bash /vagrant/tz-local/resource/monitoring/install.sh

##################################################################
# call jenkins install script
##################################################################
bash /vagrant/tz-local/resource/jenkins/install.sh

##################################################################
# call tz-py-crawler app in k8s
##################################################################
#bash /vagrant/tz-local/resource/tz-py-crawler/install.sh

exit 0

bash /vagrant/tz-local/resource/kafka/install.sh