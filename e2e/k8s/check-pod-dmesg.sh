#!/bin/bash
# Script to check if deployment pods and svc are OK.
WORKDIR=${WORKDIR:-.}
WORKDIR=$WORKDIR bash $WORKDIR/e2e/k8s/clean-deployment.sh;

# If a image is defined as variable then we switch the value in the deploy file;
if [ -n "$IMAGE" ]; then
  sed -i "s/image: .*:devel/image: ${IMAGE}/g" $WORKDIR/deployments/tmp/${DEPLOY}.yaml;
fi

kubectl apply -f $WORKDIR/deployments/tmp/${DEPLOY}.yaml && sleep 30s;
STATUS=$(kubectl get pods | grep envoy | awk '{print $3}');
if [ "$STATUS" == "Running" ]; then
  echo "OK: pod running.";
  POD=$(kubectl get pods | grep envoy | awk '{print $1}');
  if [ -n "$CONTAINER" ]; then
    kubectl exec ${POD} -c ${CONTAINER} dmesg | grep -i ioctl
    OUT=$(kubectl exec ${POD} -c ${CONTAINER} dmesg | grep -i ioctl | grep -i invalid)
  else
    kubectl exec ${POD} dmesg | grep -i ioctl
    OUT=$(kubectl exec ${POD} dmesg | grep -i ioctl | grep -i invalid)
  fi
  # if $OUT is not empty, then some invalid ioctl messages were found.
  if [ -n "$OUT" ]; then
    echo "ERROR: Invalid ioctl messages found."
    exit 1;
  fi
else
  echo "ERROR: pod not running.";
  exit 1;
fi
