#!/bin/bash

set -eo pipefail

dir=$(dirname $0)
source $dir/.includes.sh

check_executables
check_helm_chart "nickytd/kubernetes-logging"

if [[ "$1" == "-h" ]]; then
   echo "## installs kubernetes logging stack ##"
   echo "   supported options:"
   echo "     --simple"
   echo "         provisions single node opensearch cluster"
   echo "     --extended"
   echo "         provisions coordination, cluster_manager and data opensearch nodes"
   echo "     --ha-extended"
   echo "         adds kafka message brokers to the extended case"
   exit
fi

values="$dir/ofd-simple-values.yaml"

for var in "$@"; do
  if [[ "$var" = "--simple" ]]; then
    values="$dir/ofd-simple-values.yaml"
  fi

  if [[ "$var" = "--extended" ]]; then
    values="$dir/ofd-extended-values.yaml"
  fi

  if [[ "$var" = "--ha-extended" ]]; then
    values="$dir/ofd-ha-extended-values.yaml"
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

for var in "$@"; do
  if [[ "$var" = "--exporter" ]]; then
    echo " installing elasticsearch exporter"

      helm upgrade exporter \
        -n logging -f "$dir/elasticsearch-exporter.yaml" \
        prometheus-community/prometheus-elasticsearch-exporter \
        --install
  fi
done