#!/bin/bash
# Script to check if svc in deployment is accesible.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/lbd2/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  WORKDIR=$WORKDIR DEPLOY=boringssl-envoy-deployment bash $WORKDIR/e2e/k8s/check-svc.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment bash $WORKDIR/e2e/k8s/check-svc.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k8s/check-svc.sh
fi
