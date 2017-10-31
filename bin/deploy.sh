#!/bin/bash

set -o errexit
set -o nounset

# Currently using the same version tag for all phub services
export AWS_DSP_TOOLSET_VERSION=v1.2.6

export DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO:?'[error] Please specify which instance to deploy to'}

export TRIGGER_SLEEP_SECONDS=5m

case ${DRONE_DEPLOY_TO} in
  'testing')
    export KUBE_NAMESPACE=jupyterhub
    export KUBE_SERVER=${KUBE_SERVER_ACP_TESTING}
    export KUBE_TOKEN=${KUBE_TOKEN_ACP_TESTING}

    ;;

  *)
    echo '[error] unknown deploy to target specified (in \$DRONE_DEPLOY_TO)'
    exit 1

esac

echo "--- Kube API URL: ${KUBE_SERVER}"
echo "--- Kube namespace: ${KUBE_NAMESPACE}"

kubectl --namespace=${KUBE_NAMESPACE} create secret generic hub-secret \
  --from-literal=proxy.token=${PROXY_SECRET}

kd --insecure-skip-tls-verify \
  --timeout 10m0s \
  -f kube/hub-configmap.yaml \
  -f kube/hub-pvc.yaml \
  -f kube/hub-deployment.yaml \
  -f kube/hub-service.yaml \
  -f kube/proxy-deployment.yaml \
  -f kube/proxy-service.yaml \
  -f kube/ingress.yaml \
  -f kube/serviceaccount.yaml
