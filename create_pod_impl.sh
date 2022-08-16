#!/bin/bash

sudo sysctl --write net.ipv4.ip_forward=1

clear_pod() {
  local NO=$1
  sudo ip netns delete vm${NO}_pod >/dev/null 2>&1
}

function create_pod() {
  local NO=$1
  local PODIP=10.233.$1.10
  sudo ip netns add vm${NO}_pod
  sudo ip link add dev veth_vm${NO} type veth peer veth_vm${NO}_pod
  sudo ip link set dev veth_vm${NO} up
  sudo ip link set dev veth_vm${NO}_pod netns vm${NO}_pod
  sudo ip netns exec vm${NO}_pod ip link set dev lo up
  sudo ip netns exec vm${NO}_pod ip link set dev veth_vm${NO}_pod up
  sudo ip netns exec vm${NO}_pod ip address add ${PODIP} dev veth_vm${NO}_pod
  sudo ip netns exec vm${NO}_pod ip route add default via ${PODIP}
  sudo ip route add ${PODIP} dev veth_vm${NO}
}


function set_iptables() {
  local NO=$1
  sudo iptables --append FORWARD --in-interface eth1 --out-interface veth_vm${NO} --jump ACCEPT
  sudo iptables --append FORWARD --in-interface veth_vm${NO} --out-interface eth1 --jump ACCEPT
  sudo iptables --append POSTROUTING --table nat --out-interface eth1 --jump MASQUERADE
}


function usage() {
  echo "$0 <idx>"
  echo "idx - the index of the node, started with 1"
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

clear_pod $1
create_pod $1
set_iptables $1
