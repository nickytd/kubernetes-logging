#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
source $dir/.includes.sh

check_executables
check_helm_chart "nickytd/kubernetes-logging"

echo "setting up kubernetes logging stack"

kubectl create namespace logging \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade ofd nickytd/kubernetes-logging \
  -n logging -f $dir/logging-values.yaml \
  --install --wait --timeout 15m
