#!/bin/bash
# Uso: ./init_worker.sh <nombre_OvS> <iface1> [iface2 ...]
# Crea el OvS del worker y conecta las interfaces de data (troncales hacia el OFS).
set -e
[ $# -lt 2 ] && { echo "Uso: $0 <nombre_OvS> <iface1> [iface2 ...]"; exit 1; }
OVS=$1; shift
ovs-vsctl --may-exist add-br "$OVS"
ip link set "$OVS" up
for IF in "$@"; do
  ip addr flush dev "$IF"
  ovs-vsctl --may-exist add-port "$OVS" "$IF"
  ip link set "$IF" up
done
echo "[OK] Worker inicializado: $OVS con puertos $*"
