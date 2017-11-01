#!/bin/bash

set -o errexit
set -o nounset

# Currently using the same version tag for all phub services
export AWS_DSP_TOOLSET_VERSION=v1.2.6

export DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO:-testing}

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

kd --insecure-skip-tls-verify \
  --timeout 10m0s \
  -f kube/hub-configmap.yaml \
  -f kube/hub-pvc.yaml \
  -f kube/hub-deployment.yaml \
  -f kube/hub-service.yaml \
  -f kube/hub-ingress.yaml \
  -f kube/hub-serviceaccount.yaml
