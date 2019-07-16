#!/bin/bash
# Run handshake1 and loopback1 test over k8s.
if [ -z "$HOST" ]; then
  # TODO: extend posibility to run this test in an external machine,
  # such lbd5, handshake1 and loopback1 does.
  WORKDIR=$PWD
  cd $WORKDIR/vagrant
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR bash $WORKDIR/e2e/tests/k8s1/run.sh"
else
  WORKDIR=${WORKDIR:-.}
  WORKDIR=${WORKDIR} DEPLOY=envoy-deployment RUN=k8s TEST=handshake1 TAG=openssl bash ${WORKDIR}/e2e/k6/run.sh
  WORKDIR=${WORKDIR} DEPLOY=envoy-deployment RUN=k8s TEST=handshake1 TAG=openssl-clr IMAGE=envoy-qat:clr bash ${WORKDIR}/e2e/k6/run.sh
  WORKDIR=${WORKDIR} DEPLOY=boringssl-envoy-deployment RUN=k8s TEST=handshake1 TAG=boringssl bash ${WORKDIR}/e2e/k6/run.sh
  WORKDIR=${WORKDIR} DEPLOY=boringssl-nginx-behind-envoy-deployment RUN=k8s TEST=loopback1 TAG=boringssl bash ${WORKDIR}/e2e/k6/run.sh
  WORKDIR=${WORKDIR} DEPLOY=nginx-behind-envoy-deployment RUN=k8s TEST=loopback1 TAG=openssl bash ${WORKDIR}/e2e/k6/run.sh
  WORKDIR=${WORKDIR} DEPLOY=nginx-behind-envoy-deployment RUN=k8s TEST=loopback1 TAG=openssl-clr IMAGE=envoy-qat:clr bash ${WORKDIR}/e2e/k6/run.sh
fi
