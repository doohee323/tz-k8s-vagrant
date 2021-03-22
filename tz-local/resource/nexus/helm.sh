#!/usr/bin/env bash

helm repo add oteemocharts https://oteemo.github.io/charts
helm search repo oteemocharts/sonatype-nexus
helm repo update
helm install nexus oteemocharts/sonatype-nexus -f /vagrant/tz-local/resource/nexus/values.yaml -n sonatype-nexus
#helm delete nexus -n sonatype-nexus

#helm upgrade my-release stable/sonatype-nexus -f values.yaml -n sonatype-nexus --wait

