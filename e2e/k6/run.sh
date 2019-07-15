#!/bin/bash
# Script to check if deployment is incrementing QAT fw_counters under stress test.
source ./e2e/vars.sh

for CPU in ${CPUS[@]}; do
  ./e2e/k8s/clean-deployment.sh;
  sed -i "s/cpu: [2-3]/cpu: $CPU/g" ./deployments/${DEPLOY}.yaml;
  if [ -n "$IMAGE" ]; then
    sed -i "s/image: .*:devel/image: ${IMAGE}/g" ./deployments/${DEPLOY}.yaml;
  fi
  kubectl apply -f ./deployments/${DEPLOY}.yaml;
  ./e2e/k8s/wait-envoy.sh;
  STATUS=$(kubectl get pods | grep envoy | awk '{print $3}');
  if [ "$STATUS" == "Running" ]; then
    for CIPHER in ${CIPHERS[@]}; do
      echo "'$DEVICE_TYPE' running '$TEST' with '$TAG' using '$CPU cpus' and testing '$CIPHER' cipher-suite."
      if [ "$RUN" == "k8s" ]; then
        CIPHER_SUITE="$CIPHER" ./e2e/k8s/configure-k6.sh;
        kubectl create configmap k6-config --from-file=./tests/k6-testing-config.js;
        kubectl create -f ./jobs/k6.yaml;
        sleep 30s;
        kubectl logs jobs/benchmark;
      else
        CIPHER_SUITE="$CIPHER" ./e2e/docker/configure-k6.sh;
        # If K6 is required to run externally from the cluster. then we pass the,
        # js config file and run the container in the k6 runner.
        if [ -n "$CLIENT" ]; then
          scp -i ./key.pem -oStrictHostKeyChecking=no ./tests/k6-testing-config-docker.js ${CLIENT}:/tmp/
          ssh -i ./key.pem -oStrictHostKeyChecking=no ${CLIENT} "docker run --net=host -i loadimpact/k6:master run --out influxdb=http://k8s-ci-analytics.zpn.intel.com:8086/$DEVICE_TYPE --vus 30 --duration 20s -< /tmp/k6-testing-config-docker.js";
          ssh -i ./key.pem -oStrictHostKeyChecking=no ${CLIENT} "rm -rf /tmp/k6-testing-config-docker.js"
        else
          docker run --net=host -i loadimpact/k6:master run --out influxdb=http://k8s-ci-analytics.zpn.intel.com:8086/${DEVICE_TYPE} --vus 30 --duration 20s -< ./tests/k6-testing-config-docker.js;
        fi
      fi
    done
  else
    echo "Skipping test of ciphers for $CPU cpus, not sufficient resources in $HOSTNAME.";
    break;
  fi
done
