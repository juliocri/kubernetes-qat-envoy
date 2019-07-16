#!/bin/bash
# Script to check if deployment is incrementing QAT fw_counters under stress test.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/lbd4/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  WORKDIR=$WORKDIR DEPLOY=boringssl-envoy-deployment bash $WORKDIR/e2e/k8s/multiple-check-counters.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment bash $WORKDIR/e2e/k8s/multiple-check-counters.sh
  WORKDIR=$WORKDIR DEPLOY=envoy-deployment IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k8s/multiple-check-counters.sh
fi
