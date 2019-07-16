#!/bin/bash
# Script to retrieve qat images from the internal registry
DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"127.0.0.1:5000"}

docker pull ${DOCKER_QAT_REGISTRY}/envoy-qat:devel
docker pull ${DOCKER_QAT_REGISTRY}/envoy-qat:clr
docker pull ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:devel
docker pull ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:devel

docker tag ${DOCKER_QAT_REGISTRY}/envoy-qat:devel envoy-qat:devel
docker tag ${DOCKER_QAT_REGISTRY}/envoy-qat:clr envoy-qat:clr
docker tag ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:devel envoy-boringssl-qat:devel
docker tag ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:devel intel-qat-plugin:devel
