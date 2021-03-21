#!/usr/bin/env bash

helm upgrade my-release stable/sonatype-nexus -f values.yaml -n sonatype-nexus --wait

