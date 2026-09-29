#!/bin/bash
# Uso: ./no_routing_networks.sh <VLAN_A> <VLAN_B>
# Elimina el enrutamiento entre dos redes (vuelven a quedar aisladas).
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_A> <VLAN_B>"; exit 1; }
A=gw_vlan$1; B=gw_vlan$2
iptables -D FORWARD -i $A -o $B -j ACCEPT 2>/dev/null
iptables -D FORWARD -i $B -o $A -j ACCEPT 2>/dev/null
echo "[OK] Enrutamiento deshabilitado entre VLAN $1 y VLAN $2"
