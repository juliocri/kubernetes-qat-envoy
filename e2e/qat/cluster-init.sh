#!/bin/bash
# Install qat driver, docker, k8s, downloads required images and deploy qat plugin,
# using scripts in vagrant dir.
if [ -z "$HOST" ]; then
  WORKDIR=$PWD
  cd ./vagrant
  modify_host=1 bash ./setup.sh -p libvirt
  vagrant up && sleep 10s
  # Expose virtual machine oustside of host network.
  IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
  VMIP=$(vagrant ssh-config | grep HostName | awk '{print $2}')
  # Clean iptables before to create rules for the VM redirection.
  iptables -F
  iptables -X
  iptables -t nat -F
  iptables -t nat -X
  iptables -t mangle -F
  iptables -t mangle -X
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  # Redirect host traffic to VM.
  iptables -t nat -A PREROUTING -i $IFACE -p tcp --dport 30000:32767 -j DNAT --to $VMIP:30000-32767
  iptables -t nat -A POSTROUTING -j MASQUERADE
  # Provide vm with qat driver and qat_plugin for kubernetes.
  HOSTIP=$(hostname -I | awk '{print $1}')
  DOCKER_QAT_REGISTRY=${DOCKER_QAT_REGISTRY:-"$HOSTIP:5000"}
  vagrant ssh -c "sudo HOST=false WORKDIR=$WORKDIR DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY bash $WORKDIR/e2e/qat/cluster-init.sh"
else
  WORKDIR=${WORKDIR:-.}
  cd ${WORKDIR}/vagrant
  sed -i s:'/home/vagrant/kubernetes-qat-envoy/':${WORKDIR}:g krd-vars.yml
  DOCKER_QAT_REGISTRY=$DOCKER_QAT_REGISTRY CPU_MANAGER_POLICY=static bash ./installer.sh
fi
