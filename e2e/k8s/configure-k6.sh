#!/bin/bash
# Script to check if nginx svc is running and accessible and then configures,
# the script file.
WORKDIR=${WORKDIR:-.}
K6_HOST=${K6_HOST:-"127.0.0.1"}

kubectl delete job benchmark --ignore-not-found=true
kubectl delete configmap k6-config  --ignore-not-found=true

rm -rf ${WORKDIR}/tests/tmp
mkdir -p ${WORKDIR}/tests/tmp
cp -r ${WORKDIR}/tests/*.js ${WORKDIR}/tests/tmp/

SVC_PORT=$(kubectl get svc | grep hello | awk '{print $5}' | cut -d":" -f 2 | cut -d"/" -f 1)
sed -i s/'${__ENV.HELLONGINX_SERVICE_HOST}'/${K6_HOST}/g $WORKDIR/tests/tmp/k6-testing-config.js
sed -i "s/9000/$SVC_PORT/g" $WORKDIR/tests/tmp/k6-testing-config.js
if [ -n "$CIPHER_SUITE" ]; then
  sed -i "s/TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256/$CIPHER_SUITE/g" $WORKDIR/tests/tmp/k6-testing-config.js;
fi
