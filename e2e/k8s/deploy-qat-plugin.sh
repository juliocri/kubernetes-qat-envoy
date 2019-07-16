#!/bin/bash
# Script to deploy k8s plugin for QAT
WORKDIR=${WORKDIR:-$PWD}
cd $WORKDIR/vagrant
ansible-playbook -vvv -i inventory/hosts.ini configure-qat-envoy.yml -e qat_envoy_dest=$WORKDIR --tags="plugin"
