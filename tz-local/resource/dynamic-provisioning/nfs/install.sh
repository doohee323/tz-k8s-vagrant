#!/usr/bin/env bash

shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

# install NFS in k8s
https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/nfs-provisioner/README.md

kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nfs-server.yaml

Install NFS CSI driver master version on a kubernetes cluster
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/install-driver.sh | bash -s master --

kubectl -n kube-system get pod -o wide -l app=csi-nfs-controller
kubectl -n kube-system get pod -o wide -l app=csi-nfs-node

kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nginx-pod.yaml
kubectl exec nginx-nfs-example -- bash -c "findmnt /var/www -o TARGET,SOURCE,FSTYPE"

kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nginx-pod.yaml

# make default storage with NFS

k delete -f nfs-test.yaml
k delete -f nfs-claim.yaml
k delete -f nfs.yaml
k delete -f serviceaccount.yaml

k apply -f serviceaccount.yaml
k apply -f nfs.yaml
k apply -f nfs-claim.yaml
k apply -f nfs-test.yaml

exit 0