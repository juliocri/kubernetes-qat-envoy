#!/bin/bash
WORKDIR=${WORKDIR:-.}
cd $WORKDIR/vagrant
source _commons.sh
configure_ansible_ssh_keys
generates_inventory_file
install_deps
