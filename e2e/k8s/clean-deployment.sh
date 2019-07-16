#!/bin/bash
# Script to delete nginx deploy.
WORKDIR=${WORKDIR:-.}

kubectl delete -f ${WORKDIR}/deployments/nginx-behind-envoy-deployment-no-qat.yaml --ignore-not-found=true
kubectl delete -f ${WORKDIR}/deployments/boringssl-envoy-deployment.yaml --ignore-not-found=true
kubectl delete -f ${WORKDIR}/deployments/boringssl-nginx-behind-envoy-deployment.yaml --ignore-not-found=true
kubectl delete -f ${WORKDIR}/deployments/envoy-deployment.yaml --ignore-not-found=true

rm -rf ${WORKDIR}/deployments/tmp/
mkdir -p ${WORKDIR}/deployments/tmp
cp -r ${WORKDIR}/deployments/*.yaml ${WORKDIR}/deployments/tmp/
sed -i "s/- name: nginx/- name: nginx\n          securityContext:\n            privileged: true/g" ${WORKDIR}/deployments/tmp/nginx-behind-envoy-deployment.yaml
sed -i "s/- name: envoy-sidecar/- name: envoy-sidecar\n          securityContext:\n            privileged: true/g" ${WORKDIR}/deployments/tmp/nginx-behind-envoy-deployment.yaml

sleep 45s
