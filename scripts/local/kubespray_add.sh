#!/usr/bin/env bash

# add a new node
#https://www.techbeatly.com/adding-new-nodes-to-kubespray-managed-kubernetes-cluster/

#set -x

if [ -d /vagrant ]; then
  cd /vagrant
fi

cp -Rf resource/kubespray/inventory2.ini kubespray/inventory/test-cluster/inventory.ini
cp -Rf resource/kubespray/hosts.yaml    kubespray/inventory/test-cluster/hosts.yaml

cd kubespray

ansible all -i inventory/test-cluster/inventory.ini -m ping

#declare -a IPS=(192.168.0.127 192.168.0.128 192.168.0.129)
#CONFIG_FILE=inventory/test-cluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

cat inventory/test-cluster/group_vars/all/all.yml
cat inventory/test-cluster/group_vars/k8s-cluster/k8s-cluster.yml

#ansible-playbook -i inventory/test-cluster/hosts.yaml  --become --become-user=root cluster.yml
#ansible-playbook -i inventory/test-cluster/hosts.yaml cluster.yml -u devops -b -l node-3
ansible-playbook -i inventory/test-cluster/hosts.yaml cluster.yml -b -become-user=root -l node4

exit 0

sudo cp -Rf /root/.kube /home/vagrant/
sudo chown -Rf vagrant:vagrant /home/vagrant/.kube

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
exec bash

kubectl get nodes
kubectl cluster-info

sudo cp -Rf /root/.kube/config kubespray_vagrant

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

#k delete -f tz-local/resource/standard-storage.yaml
k apply -f tz-local/resource/standard-storage.yaml
k patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k get storageclass,pv,pvc

helm repo add stable https://charts.helm.sh/stable
helm repo update

# nfs
# 1. with helm
#helm repo update
#helm install my-release --set nfs.server=192.168.0.127 --set nfs.path=/srv/nfs/mydata stable/nfs-client-provisioner
# 2. with manual
#k apply -f tz-local/resource/dynamic-provisioning/nfs/static-nfs.yaml
#k apply -f tz-local/resource/dynamic-provisioning/nfs/serviceaccount.yaml
#k apply -f tz-local/resource/dynamic-provisioning/nfs/nfs.yaml
#k apply -f tz-local/resource/dynamic-provisioning/nfs/nfs-claim.yaml

echo "## [ install helm3 ] ######################################################"
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo bash get_helm.sh
sudo rm -Rf get_helm.sh

sleep 10

#k get po -n kube-system

sudo rm -Rf info

##################################################################
# call nfs dynamic-provisioning
##################################################################
bash tz-local/resource/dynamic-provisioning/nfs/install.sh

##################################################################
# call metallb
##################################################################
bash tz-local/resource/metallb/install.sh

##################################################################
# call dashboard install script
##################################################################
#bash tz-local/resource/dashboard/install.sh

##################################################################
# call monitoring install script
##################################################################
bash tz-local/resource/monitoring/install.sh

##################################################################
# call jenkins install script
##################################################################
#bash tz-local/resource/jenkins/install.sh

##################################################################
# call tz-py-crawler app in k8s
##################################################################
#bash tz-local/resource/tz-py-crawler/install.sh

exit 0

bash tz-local/resource/kafka/install.sh