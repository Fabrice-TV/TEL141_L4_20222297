#!/bin/bash
# Uso: internet_to_network.sh <VLAN_ID> <red_CIDR>
# NAT (MASQUERADE) de la VLAN hacia la interfaz con ruta por defecto (ens3).
[ $# -ne 2 ] && { echo "Uso: $0 <VLAN_ID> <red_CIDR>"; exit 1; }
VLAN=$1; NET=$2; GWIF=gw_vlan$VLAN
WAN=$(ip route show default | awk '{print $5; exit}')
iptables -t nat -C POSTROUTING -s $NET -o $WAN -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -s $NET -o $WAN -j MASQUERADE
iptables -C FORWARD -i $GWIF -o $WAN -s $NET -j ACCEPT 2>/dev/null || \
  iptables -A FORWARD -i $GWIF -o $WAN -s $NET -j ACCEPT
iptables -C FORWARD -i $WAN -o $GWIF -d $NET -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
  iptables -A FORWARD -i $WAN -o $GWIF -d $NET -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "[OK] Internet habilitado: VLAN $VLAN ($NET) via $WAN"
