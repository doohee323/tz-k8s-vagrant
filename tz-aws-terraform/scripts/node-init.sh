#!/bin/bash

DEVICE=$1
count_index=$2

echo $DEVICE > /home/ubuntu/debug
echo $count_index >> /home/ubuntu/debug

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
