#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2019 Intel Corporation
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o xtrace
set -o errexit
set -o nounset

source _commons.sh

./prechecks.sh

# Configure SSH keys for ansible communication
configure_ansible_ssh_keys
generates_inventory_file

# Install dependencies
install_deps

# QAT Driver installation
ansible-playbook -vvv -i ./inventory/hosts.ini configure-qat.yml | tee setup-qat.log

# QAT Plugin installation
install_docker

# Kubernetes installation
CPU_MANAGER_POLICY=${CPU_MANAGER_POLICY:-none} install_k8s

# If DOCKER_QAT_REGISTRY is set, then we pull images on there,
# and we can skip local builds on next steps.
tags=""
if [ -n "${DOCKER_QAT_REGISTRY}" ]; then
  tags="--tags \"driver,plugin\""
  DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash ../e2e/docker/set-registry.sh
  DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash ../e2e/docker/pull-internal-images.sh
fi

# Deploy qat-plugin
# set tags to be installed example: `--tags="driver,plugin"`,
# leave blank to install all the ansible playbook.
sudo sh -c "ansible-playbook -vvv -i ./inventory/hosts.ini configure-qat-envoy.yml $tags | tee setup-qat-envoy.log"

# Kata containers configuration
if [[ "${CONTAINER_MANAGER:-docker}" == "crio" ]]; then
    sudo -E pip install PyYAML
    kube_version=$(parse_yaml inventory/group_vars/k8s-cluster.yml "['kube_version']")
    if vercmp "${kube_version#*v}" '<' 1.14; then
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/release-1.13/cluster/addons/runtimeclass/runtimeclass_crd.yaml
        kubectl apply -f kata-qemu.yml
    else
        kubectl apply -f https://raw.githubusercontent.com/clearlinux/cloud-native-setup/master/clr-k8s-examples/8-kata/kata-qemu-runtimeClass.yaml
    fi

    kubectl apply -f https://raw.githubusercontent.com/kata-containers/packaging/master/kata-deploy/kata-rbac.yaml
    kubectl apply -f https://raw.githubusercontent.com/kata-containers/packaging/master/kata-deploy/kata-deploy.yaml
    sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2
    for img in intel-qat-plugin envoy-qat; do
        sudo docker tag "${img}:devel" "localhost:5000/${img}:devel"
        sudo docker push "localhost:5000/${img}:devel"
    done
    kubectl set image daemonset/intel-qat-kernel-plugin intel-qat-kernel-plugin=localhost:5000/intel-qat-plugin:devel
fi

./postchecks_qat_plugin.sh
# Deploy K8s secrets to be ready for sample and/or tests.
install_tls_secrets
