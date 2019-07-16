#!/bin/bash
# Clean cluster.
if [ -z "$HOST" ]; then
  cd ./vagrant
  # destroy vagrant machine.
  vagrant destroy --force
else
  ./e2e/k8s/clean.sh
  ./e2e/docker/clean.sh
fi

# Clean iptables in host, wheater if the execution was in host/guest.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
