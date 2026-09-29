#!/bin/bash
# Uso: ./no_internet_to_network.sh <VLAN_ID> <iface_internet>
# Retira la salida a Internet de la red VLAN (elimina NAT y reglas FORWARD).
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_ID> <iface_internet>"; exit 1; }
VLAN=$1; WAN=$2; GWIF=gw_vlan$VLAN
NET=$(python3 -c "import ipaddress,sys;print(ipaddress.ip_interface(sys.argv[1]).network)" \
      "$(ip -o -4 addr show "$GWIF" | awk '{print $4}')")

iptables -t nat -D POSTROUTING -s "$NET" -o "$WAN" -j MASQUERADE 2>/dev/null
iptables -D FORWARD -i "$GWIF" -o "$WAN" -j ACCEPT 2>/dev/null
iptables -D FORWARD -i "$WAN" -o "$GWIF" -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null

echo "[OK] Internet deshabilitado para VLAN $VLAN ($NET)"
