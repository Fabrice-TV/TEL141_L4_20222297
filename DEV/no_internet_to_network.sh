#!/bin/bash
# Uso: no_internet_to_network.sh <VLAN_ID> <red_CIDR>
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_ID> <red_CIDR>"; exit 1; }
VLAN=$1; NET=$2; GWIF=gw_vlan$VLAN
WAN=$(ip route show default | awk '{print $5; exit}')
while iptables -t nat -D POSTROUTING -s $NET -o $WAN -j MASQUERADE 2>/dev/null; do :; done
while iptables -D FORWARD -i $GWIF -o $WAN -s $NET -j ACCEPT 2>/dev/null; do :; done
while iptables -D FORWARD -i $WAN -o $GWIF -d $NET -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null; do :; done
echo "[OK] Internet deshabilitado: VLAN $VLAN ($NET)"
