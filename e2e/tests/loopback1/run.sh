#!/bin/bash
# run loopback1 test with all deployments.
# If private key is gotten from jenkins, we also specify user and ip for a remote,
# k6 execution.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd $WORKDIR/vagrant
  # Check for ssk key, if its set then the execution of the test will be in other,
  # machine (no localhost);
  if [ -n "$SSH_KEY" ]; then
    mkdir -p $WORKDIR/tmp
    cat $SSH_KEY > $WORKDIR/tmp/ssh-key.pub && chmod 400 $WORKDIR/tmp/ssh-key.pub
    SSH_KEY=$WORKDIR/tmp/ssh-key.pub
    HOSTIP=$(hostname -I | awk '{print $1}')
    vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR SSH_KEY=$SSH_KEY SSH_HOST=$HOSTIP SSH_CLIENT=$K6_RUNNER bash $WORKDIR/e2e/tests/loopback1/run.sh"
  else
    vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/loopback1/run.sh"
  fi
else
  WORKDIR=${WORKDIR:-.}
  if [ -n "$SSH_KEY" ]; then
    WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} K6_HOST=${SSH_HOST} K6_CLIENT=${SSH_CLIENT} DEPLOY=envoy-deployment RUN=docker TEST=loopback1 TAG=openssl bash $WORKDIR/e2e/k6/run.sh
    WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} K6_HOST=${SSH_HOST} K6_CLIENT=${SSH_CLIENT} DEPLOY=envoy-deployment RUN=docker TEST=loopback1 TAG=openssl-clr IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k6/run.sh
    WORKDIR=${WORKDIR} SSH_KEY=${SSH_KEY} K6_HOST=${SSH_HOST} K6_CLIENT=${SSH_CLIENT} DEPLOY=boringssl-envoy-deployment RUN=docker TEST=loopback1 TAG=boringssl bash $WORKDIR/e2e/k6/run.sh
    rm -rf $WORKDIR/tmp
  else
    WORKDIR=${WORKDIR} DEPLOY=envoy-deployment RUN=docker TEST=loopback1 TAG=openssl bash $WORKDIR/e2e/k6/run.sh
    WORKDIR=${WORKDIR} DEPLOY=envoy-deployment RUN=docker TEST=loopback1 TAG=openssl-clr IMAGE=envoy-qat:clr bash $WORKDIR/e2e/k6/run.sh
    WORKDIR=${WORKDIR} DEPLOY=boringssl-envoy-deployment RUN=docker TEST=loopback1 TAG=boringssl bash $WORKDIR/e2e/k6/run.sh
  fi
fi
