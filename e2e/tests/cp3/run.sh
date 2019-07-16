#!/bin/bash
# Script to deploy intel_qat_plugin (kernel mode) using tasks in vagrant dir.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash $WORKDIR/e2e/tests/cp3/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  # Pull images recently built and then deploy the plugin.
  DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"127.0.0.1:5000"}
  DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash $WORKDIR/e2e/docker/set-registry.sh
  DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash $WORKDIR/e2e/docker/pull-internal-images.sh
  WORKDIR=$WORKDIR bash $WORKDIR/e2e/k8s/deploy-qat-plugin.sh
  WORKDIR=$WORKDIR bash $WORKDIR/vagrant/postchecks_qat_plugin.sh
fi
