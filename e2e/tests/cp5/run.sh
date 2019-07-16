#!/bin/bash
# to chek if deployment is ready and pod have set proper env variables.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/cp5/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  WORKDIR=$WORKDIR DEPLOY=boringssl-envoy-deployment bash $WORKDIR/e2e/k8s/check-pod-env.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment bash $WORKDIR/e2e/k8s/check-pod-env.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k8s/check-pod-env.sh
fi
