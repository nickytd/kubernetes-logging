#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
source $dir/.includes.sh

check_executables
check_helm_chart "nickytd/kubernetes-logging"

values="$dir/logging-values-extended.yaml"

for var in "$@"; do
  if [[ "$var" = "--simple" ]]; then
    values="$dir/logging-values-simple.yaml"
  fi
done

echo "setting up kubernetes logging stack with $values"
kubectl create namespace logging \
  --dry-run=client -o yaml | kubectl apply -f -

if [ -f "$dir/ssl/ca.pem" ]; then

helm upgrade ofd nickytd/kubernetes-logging \
  --set-file opensearch.oidc.cacerts=$dir/ssl/ca.pem \
  -n logging -f $values \
  --install --timeout 15m

else

helm upgrade ofd nickytd/kubernetes-logging \
  -n logging -f $values \
  --install --timeout 15m

fi