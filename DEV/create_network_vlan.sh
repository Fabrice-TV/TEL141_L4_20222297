#!/bin/bash
# Uso: create_network_vlan.sh <VLAN_ID> <red_CIDR> <dhcp: on|off> [inicio,fin]
# Ej:  create_network_vlan.sh 100 192.168.0.0/24 on 192.168.0.10,192.168.0.100
# Gateway gw_vlanX = 1ra direccion de la red; DHCP (namespace) = 2da direccion.
[ $# -lt 3 ] && { echo "Uso: $0 <VLAN_ID> <red_CIDR> <on|off> [inicio,fin]"; exit 1; }
VLAN=$1; NET=$2; DHCP=$3; RANGE=$4; OVS=br-int
read GW DHCPIP MASK PREFIX <<< $(python3 -c "
import ipaddress,sys; n=ipaddress.ip_network(sys.argv[1])
print(n.network_address+1, n.network_address+2, n.netmask, n.prefixlen)" "$NET")

# 1) Gateway: puerto interno con tag
GWIF=gw_vlan$VLAN
ovs-vsctl --may-exist add-port $OVS $GWIF tag=$VLAN -- set interface $GWIF type=internal
ip addr replace $GW/$PREFIX dev $GWIF
ip link set $GWIF up
echo "[OK] Gateway $GWIF = $GW/$PREFIX"

# 2) DHCP en namespace (puerto interno movido al namespace)
case "$DHCP" in on|ON|si|1|true) ;; *) echo "[OK] VLAN $VLAN sin DHCP"; exit 0;; esac
[ -z "$RANGE" ] && { echo "Falta rango DHCP inicio,fin"; exit 1; }
NS=ns-dhcp-vlan$VLAN; DIF=dhcp_vlan$VLAN
ip netns add $NS 2>/dev/null || true
ovs-vsctl --may-exist add-port $OVS $DIF tag=$VLAN -- set interface $DIF type=internal
ip link set $DIF netns $NS 2>/dev/null || true
ip netns exec $NS ip link set lo up
ip netns exec $NS ip addr replace $DHCPIP/$PREFIX dev $DIF
ip netns exec $NS ip link set $DIF up
PID=/run/dnsmasq-vlan$VLAN.pid
[ -f $PID ] && kill $(cat $PID) 2>/dev/null
ip netns exec $NS dnsmasq --interface=$DIF --bind-interfaces \
  --dhcp-range=$RANGE,$MASK,12h --dhcp-option=3,$GW --dhcp-option=6,8.8.8.8 \
  --pid-file=$PID --dhcp-leasefile=/var/lib/misc/dnsmasq-vlan$VLAN.leases >/dev/null 2>&1
echo "[OK] DHCP VLAN $VLAN en $NS ($DHCPIP), rango $RANGE, router $GW"
