#!/bin/bash
# Script to retrieve qat images from the internal registry
DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"127.0.0.1:5000"}
TESTING_IMAGE_TAG=${TESTING_IMAGE_TAG:-"devel"}

docker pull ${DOCKER_QAT_REGISTRY}/envoy-qat:${TESTING_IMAGE_TAG}
#docker pull ${DOCKER_QAT_REGISTRY}/envoy-qat-clr:${TESTING_IMAGE_TAG}
#docker pull ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:${TESTING_IMAGE_TAG}
docker pull ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:${TESTING_IMAGE_TAG}

docker tag ${DOCKER_QAT_REGISTRY}/envoy-qat:${TESTING_IMAGE_TAG} envoy-qat:devel
#docker tag ${DOCKER_QAT_REGISTRY}/envoy-qat-clr:${TESTING_IMAGE_TAG} envoy-qat-clr:devel
#docker tag ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:${TESTING_IMAGE_TAG} envoy-boringssl-qat:devel
docker tag ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:${TESTING_IMAGE_TAG} intel-qat-plugin:devel
