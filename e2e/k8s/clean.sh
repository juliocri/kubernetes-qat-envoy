#!/bin/bash
# Script to clean k8s resources
# This secript cleans k8s when e2e was excuted in the host machine.
cd ./vagrant
source _commons.sh
sed -i 's/default: "no"/default: "yes"/g' $kubespray_folder/reset.yml
sed -i 's/private: no/private: yes/g' $kubespray_folder/reset.yml
echo yes | uninstall_k8s
rm -rf $kubespray_folder
