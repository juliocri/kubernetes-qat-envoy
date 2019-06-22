#!/bin/bash
# Script to delete nginx deploy.
kubectl delete -f ./deployments/ --ignore-not-found=true
git checkout ./deployments
sed -i "s/- name: nginx/- name: nginx\n          securityContext:\n            privileged: true/g" ./deployments/nginx-behind-envoy-deployment.yaml
sed -i "s/- name: envoy-sidecar/- name: envoy-sidecar\n          securityContext:\n            privileged: true/g" ./deployments/nginx-behind-envoy-deployment.yaml
# Wait until there's no envoy pods listed.
RUNNING=$(kubectl get pods | grep envoy)
while [ -n "${RUNNING}" ]; do
  echo "Waiting to terminate envoy deployments.";
  sleep 5s;
  RUNNING=$(kubectl get pods | grep envoy);
done
sleep 10s && echo "OK: deployment terminated."
