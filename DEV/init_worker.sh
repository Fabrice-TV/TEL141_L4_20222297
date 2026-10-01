#!/bin/bash
# Uso: init_worker.sh <iface1> [iface2 ...]
[ $# -lt 1 ] && { echo "Uso: $0 <iface1> [iface2 ...]"; exit 1; }
OVS=br-int
ovs-vsctl --may-exist add-br $OVS
ip link set $OVS up
for IF in "$@"; do
  ovs-vsctl --may-exist add-port $OVS "$IF"
  ip link set "$IF" up
done
echo "[OK] init_worker: $OVS con $*"
