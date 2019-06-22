#!/bin/bash
# Script to wait until envoy pod is running;
WAIT=0
TIMEOUT=360
STATUS=$(kubectl get pods | grep envoy | awk '{print $3}');
while [ "$STATUS" != "Running" ]; do
  echo "Waiting envoy pod to run."
  sleep 5s;
  STATUS=$(kubectl get pods | grep envoy | awk '{print $3}');
  WAIT=$(expr $WAIT + 5 )
  if [ "$WAIT" -gt "$TIMEOUT" ]; then
    echo "Timeout waiting envoy pod to run.";
    exit 1;
  fi
done
sleep 10s && echo "OK: envoy pod is now running, next step check."
