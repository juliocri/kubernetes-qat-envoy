#!/bin/bash
# Check if pod with QAT have ENV vars correctly set;
WORKDIR=${WORKDIR:-.}
WORKDIR=$WORKDIR bash $WORKDIR/e2e/k8s/clean-deployment.sh
# If a image is defined as variable then we switch the value in the deploy file;
if [ -n "$IMAGE" ]; then
  sudo sed -i "s/image: .*:devel/image: ${IMAGE}/g" $WORKDIR/deployments/tmp/${DEPLOY}.yaml;
fi

kubectl apply -f $WORKDIR/deployments/tmp/${DEPLOY}.yaml
sleep 30s
STATUS=$(kubectl get pods | grep envoy | awk '{print $3}')
if [ "$STATUS" == "Running" ]; then
  echo "OK: pod running.";

  POD=$(kubectl get pods | grep envoy | awk '{print $1}');
  if [ -n "$CONTAINER" ]; then
    VARS=$(kubectl exec ${POD} -c ${CONTAINER} env | grep QAT_SECTION_NAME);
  else
    VARS=$(kubectl exec ${POD} env | grep QAT_SECTION_NAME);
  fi

  if [ -z "$VARS" ]; then
    echo "ERROR: No QAT ENV vars found in pod.";
    exit 1;
  else
    echo "OK: QAT ENV vars found in pod.";
    # Check if SHIM section is granted in all env vars for QAT_SECTION_NAME_*.
    for VAR in ${VARS[@]}; do
      if [[ "$(echo $VAR | cut -d'=' -f2)" == "SHIM" ]]; then
        echo "OK: SHIM section name is granted in env variable.";
        echo $VAR;
      else
        echo "ERROR: No SHIM section name found.";
        exit 1;
      fi
    done
  fi
else
  echo "ERROR: pod not running.";
  exit 1;
fi
