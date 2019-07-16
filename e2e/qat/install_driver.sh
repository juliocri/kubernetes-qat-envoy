#!/bin/bash
WORKDIR=${WORKDIR:-.}
cd $WORKDIR/vagrant
ansible-playbook -vvv -i inventory/hosts.ini configure-qat.yml
ansible-playbook -vvv -i inventory/hosts.ini configure-qat-envoy.yml -e qat_envoy_dest=$WORKDIR --tags="driver"
