#!/bin/bash
# Uso: no_routing_networks.sh <VLAN_ID_1> <VLAN_ID_2>
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_1> <VLAN_2>"; exit 1; }
A=gw_vlan$1; B=gw_vlan$2
while iptables -D FORWARD -i $A -o $B -j ACCEPT 2>/dev/null; do :; done
while iptables -D FORWARD -i $B -o $A -j ACCEPT 2>/dev/null; do :; done
echo "[OK] Ruteo deshabilitado VLAN $1 <-> VLAN $2"
