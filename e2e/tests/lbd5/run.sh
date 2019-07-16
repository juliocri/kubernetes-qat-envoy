#!/bin/bash
# Script to check if we can get a response from envoy in other machine.
if [ -z "$HOST" ]; then
  # Check for external machine identity.
  if [ -z "$K6_RUNNER" ]; then
    echo "ERROR: '<user>@<ip-address>' for k6 runner is required.";
    exit 1;
  fi
  # Check for ssh-key to connect into a external machine with k6 running.
  if [ -z "$SSH_KEY" ]; then
    echo "ERROR: ssh key to connect to k6 runner was not specified.";
    exit 1;
  fi
  # Start execution of test.
  WORKDIR=$PWD
  cd $WORKDIR/vagrant
  mkdir -p $WORKDIR/tmp
  cat $SSH_KEY > $WORKDIR/tmp/ssh-key.pub && chmod 400 $WORKDIR/tmp/ssh-key.pub
  SSH_KEY=$WORKDIR/tmp/ssh-key.pub
  HOSTIP=$(hostname -I | awk '{print $1}')
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR SSH_KEY=$SSH_KEY SSH_HOST=$HOSTIP SSH_CLIENT=$K6_RUNNER bash $WORKDIR/e2e/tests/lbd5/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  source $WORKDIR/e2e/vars.sh
  SSH_KEY=${SSH_KEY:-"~/.ssh/id_rsa"}
  SSH_HOST=${SSH_HOST:-"127.0.0.1"}
  SSH_CLIENT=${SSH_CLIENT:-"$K6_RUNNER"}
  WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} HOST=${SSH_HOST} CLIENT=${SSH_CLIENT} DEPLOY=boringssl-envoy-deployment bash $WORKDIR/e2e/k8s/check-svc.sh
  WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} HOST=${SSH_HOST} CLIENT=${SSH_CLIENT} DEPLOY=envoy-deployment bash $WORKDIR/e2e/k8s/check-svc.sh
  WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} HOST=${SSH_HOST} CLIENT=${SSH_CLIENT} DEPLOY=envoy-deployment IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k8s/check-svc.sh
  rm -rf $WORKDIR/tmp
fi
