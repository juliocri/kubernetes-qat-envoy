#!/bin/bash
cd ./vagrant
ansible-playbook -vvv -i inventory/hosts.ini configure-qat.yml -u root
ansible-playbook -vvv -i inventory/hosts.ini configure-qat-envoy.yml --tags="driver" -u root
