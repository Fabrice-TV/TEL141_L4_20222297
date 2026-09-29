#!/bin/bash
# Uso: ./routing_networks.sh <VLAN_A> <VLAN_B>
# Permite el enrutamiento (inter-VLAN) entre dos redes en el headnode.
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_A> <VLAN_B>"; exit 1; }
A=gw_vlan$1; B=gw_vlan$2
for R in "-i $A -o $B" "-i $B -o $A"; do
  iptables -C FORWARD $R -j ACCEPT 2>/dev/null || iptables -A FORWARD $R -j ACCEPT
done
echo "[OK] Enrutamiento habilitado entre VLAN $1 y VLAN $2"
