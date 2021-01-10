#!/usr/bin/env bash

#set -x
sudo apt purge iptables-persistent -y
sudo apt install iptables-persistent -y

# backup
sudo mkdir iptables_backup
cd iptables_backup
sudo iptables-save > 20201217.rule
#sudo iptables-restore < 20201217.rule

# set default policies to let everything in
iptables --policy INPUT   ACCEPT
iptables --policy OUTPUT  ACCEPT
iptables --policy FORWARD ACCEPT

iptables -Z # zero counters
iptables -F # flush (delete) rules
iptables -X # delete all extra chains

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# master ssh port forwarding
iptables -t nat -A PREROUTING -p tcp -i eno1 --dport 2222 -j DNAT --to-destination 10.0.0.10:22
iptables -t nat -A POSTROUTING -j MASQUERADE

iptables -A PREROUTING -t nat -p tcp -i eno1 --dport 2222 -j DNAT --to 10.0.0.10:22
iptables -A POSTROUTING -t nat -j MASQUERADE

# node-1 ssh port forwarding
iptables -t nat -A PREROUTING -p tcp -i eno1 --dport 2223 -j DNAT --to-destination 10.0.0.11:22
iptables -t nat -A POSTROUTING -j MASQUERADE

iptables -A PREROUTING -t nat -p tcp -i eno1 --dport 2223 -j DNAT --to 10.0.0.11:22
iptables -A POSTROUTING -t nat -j MASQUERADE

# access outside of vagrant
ssh -p 2222 vagrant@dooheehong323
ssh -p 2223 vagrant@dooheehong323

exit 0
