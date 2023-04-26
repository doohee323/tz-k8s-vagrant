#!/usr/bin/env bash

#https://blog.ruanbekker.com/cheatsheets/alertmanager/
cd /vagrant/sl-local/resource/monitoring/service-monitor

kubectl delete -f devops-demo-devops-dev.yaml -n devops-dev
kubectl apply -f devops-demo-devops-dev.yaml -n devops-dev

kubectl delete -f twip-demo-twip-dev.yaml -n twip-dev
kubectl apply -f twip-demo-twip-dev.yaml -n twip-dev

