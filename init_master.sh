#!/bin/bash
# Uso: ./init_master.sh <nombre_OvS> <iface1> [iface2 ...]
# Crea el OvS del headnode, conecta las interfaces de data (troncales) y habilita forwarding.
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

# Forwarding habilitado; por defecto no se reenvia nada entre redes (aislamiento)
sysctl -w net.ipv4.ip_forward=1 >/dev/null
iptables -P FORWARD DROP

# dnsmasq se usara dentro de namespaces, no como servicio del sistema
command -v dnsmasq >/dev/null || apt-get install -y dnsmasq
systemctl disable --now dnsmasq 2>/dev/null || true

echo "[OK] Headnode inicializado: $OVS con puertos $*"
