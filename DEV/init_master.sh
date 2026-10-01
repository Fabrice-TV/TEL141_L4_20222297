#!/bin/bash
# Uso: init_master.sh <iface1> [iface2 ...]
# Headnode: crea br-int (si no existe), conecta interfaces, activa forwarding y FORWARD=DROP.
[ $# -lt 1 ] && { echo "Uso: $0 <iface1> [iface2 ...]"; exit 1; }
OVS=br-int
ovs-vsctl --may-exist add-br $OVS
ip link set $OVS up
for IF in "$@"; do
  ovs-vsctl --may-exist add-port $OVS "$IF"
  ip link set "$IF" up
done
sysctl -w net.ipv4.ip_forward=1 >/dev/null
iptables -P FORWARD DROP
command -v dnsmasq >/dev/null || apt-get install -y dnsmasq >/dev/null
systemctl disable --now dnsmasq >/dev/null 2>&1 || true
echo "[OK] init_master: $OVS con $*, ip_forward=1, FORWARD=DROP"
