#!/bin/bash
set -e
# Install k8s cluster
./e2e/docker/install.sh || true
./e2e/k8s/install.sh && sleep 60s
./e2e/k8s/check-cluster.sh
