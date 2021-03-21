#!/usr/bin/env bash

helm install --name my-release -f values.yaml stable/sonatype-nexus

#helm upgrade my-release stable/sonatype-nexus -f values.yaml -n sonatype-nexus --wait

