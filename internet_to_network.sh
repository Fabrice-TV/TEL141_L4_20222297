#!/bin/bash
# Uso: ./internet_to_network.sh <VLAN_ID> <iface_internet>
# Da salida a Internet a la red VLAN mediante NAT (MASQUERADE).
set -e
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_ID> <iface_internet>"; exit 1; }
VLAN=$1; WAN=$2; GWIF=gw_vlan$VLAN
NET=$(python3 -c "import ipaddress,sys;print(ipaddress.ip_interface(sys.argv[1]).network)" \
      "$(ip -o -4 addr show "$GWIF" | awk '{print $4}')")

iptables -t nat -C POSTROUTING -s "$NET" -o "$WAN" -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -s "$NET" -o "$WAN" -j MASQUERADE
iptables -C FORWARD -i "$GWIF" -o "$WAN" -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -i "$GWIF" -o "$WAN" -j ACCEPT
iptables -C FORWARD -i "$WAN" -o "$GWIF" -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -i "$WAN" -o "$GWIF" -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "[OK] Internet habilitado para VLAN $VLAN ($NET) via $WAN"
