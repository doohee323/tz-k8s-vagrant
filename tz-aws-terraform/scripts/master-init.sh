#!/bin/bash

# Install kubeadm and Docker
apt-get update
apt-get install -y apt-transport-https curl
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y docker.io kubeadm

# Run kubeadm
kubeadm init \
  --token "${local_token}" \
  --token-ttl 15m \
  --apiserver-cert-extra-sans "${aws_eip_master_public_ip}" \
  --node-name master

# Prepare kubeconfig file for download to local machine
cp /etc/kubernetes/admin.conf /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/admin.conf
kubectl --kubeconfig /home/ubuntu/admin.conf config set-cluster kubernetes --server https://${aws_eip_master_public_ip}:6443

# volume setup
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 15
    fi
  done
  sudo pvcreate ${DEVICE}
  sudo vgcreate data ${DEVICE}
  sudo lvcreate --name volume1 -l 100%FREE data
  sudo mkfs.ext4 /dev/data/volume1
fi

# Indicate completion of bootstrapping on this node
touch /home/ubuntu/done

