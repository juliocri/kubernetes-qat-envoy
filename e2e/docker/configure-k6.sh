#!/bin/bash
# Script to check if nginx svc is running and accessible and then configures,
# the script file.
WORKDIR=${WORKDIR:-.}
source $WORKDIR/e2e/vars.sh
K6_HOST=${K6_HOST:-"$HOSTIP"}

rm -rf ${WORKDIR}/tests/tmp
mkdir -p ${WORKDIR}/tests/tmp
cp -r ${WORKDIR}/tests/*.js ${WORKDIR}/tests/tmp/
SVC_PORT=$(kubectl get svc | grep hello | awk '{print $5}' | cut -d":" -f 2 | cut -d"/" -f 1)
sed -i "s/localhost/$K6_HOST/g" $WORKDIR/tests/tmp/k6-testing-config-docker.js
sed -i "s/9000/$SVC_PORT/g" $WORKDIR/tests/tmp/k6-testing-config-docker.js
if [ -n "$CIPHER_SUITE" ]; then
  sed -i "s/TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256/$CIPHER_SUITE/g" $WORKDIR/tests/tmp/k6-testing-config-docker.js;
fi
