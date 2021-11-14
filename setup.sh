#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
source $dir/.includes.sh

check_executables
check_helm_chart "nickytd/kubernetes-logging"

echo "setting up kubernetes logging stack"

kubectl create namespace logging \
  --dry-run=client -o yaml | kubectl apply -f -

if [ -f "$dir/ssl/ca.pem" ]; then

helm upgrade ofd nickytd/kubernetes-logging \
  --set-file opensearch.oidc.cacerts=$dir/ssl/ca.pem \
  -n logging -f $dir/logging-values.yaml \
  --install --timeout 15m

else

helm upgrade ofd nickytd/kubernetes-logging \
  -n logging -f $dir/logging-values.yaml \
  --install --timeout 15m

fi