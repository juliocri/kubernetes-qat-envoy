#!/bin/bash
# Script to publish qat images in the internal registry.
DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"127.0.0.1:5000"}
TESTING_IMAGE_TAG=${TESTING_IMAGE_TAG:-"devel"}

docker tag envoy-qat:devel ${DOCKER_QAT_REGISTRY}/envoy-qat:${TESTING_IMAGE_TAG}
docker tag envoy-qat-clr:devel ${DOCKER_QAT_REGISTRY}/envoy-qat-clr:${TESTING_IMAGE_TAG}
docker tag envoy-boringssl-qat:devel ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:${TESTING_IMAGE_TAG}
docker tag intel-qat-plugin:devel ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:${TESTING_IMAGE_TAG}

docker push ${DOCKER_QAT_REGISTRY}/envoy-qat:${TESTING_IMAGE_TAG}
docker push ${DOCKER_QAT_REGISTRY}/envoy-qat-clr:${TESTING_IMAGE_TAG}
docker push ${DOCKER_QAT_REGISTRY}/envoy-boringssl-qat:${TESTING_IMAGE_TAG}
docker push ${DOCKER_QAT_REGISTRY}/intel-qat-plugin:${TESTING_IMAGE_TAG}
