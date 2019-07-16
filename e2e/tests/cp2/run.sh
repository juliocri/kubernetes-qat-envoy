#!/bin/bash
# Install k8s cluster and pull images.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/cp2/run.sh"
else
  # Install docker and k8s - then check if the cluster is runnig.
  WORKDIR=${WORKDIR:-.}
  WORKDIR=$WORKDIR bash $WORKDIR/e2e/docker/install.sh
  WORKDIR=$WORKDIR bash $WORKDIR/e2e/k8s/install.sh && sleep 60s
  WORKDIR=$WORKDIR bash $WORKDIR/e2e/k8s/check-cluster.sh
fi
