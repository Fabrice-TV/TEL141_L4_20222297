#!/bin/bash
# Uso: ./create_network_vlan.sh <nombre_OvS> <VLAN_ID> <IP_gateway/prefijo> <DHCP_inicio,DHCP_fin>
# Ej:  ./create_network_vlan.sh br-int 100 192.168.10.1/24 192.168.10.10,192.168.10.50
# Crea la red VLAN: gateway (puerto interno del OvS) + servidor DHCP en un namespace.
set -e
[ $# -ne 4 ] && { echo "Uso: $0 <OvS> <VLAN_ID> <IP_gw/prefijo> <DHCP_ini,DHCP_fin>"; exit 1; }
OVS=$1; VLAN=$2; GW_CIDR=$3; RANGE=$4
GW=${GW_CIDR%/*}; PREFIX=${GW_CIDR#*/}
MASK=$(python3 -c "import ipaddress,sys;print(ipaddress.ip_interface(sys.argv[1]).netmask)" "$GW_CIDR")
DHCP_IP=$(python3 -c "import ipaddress,sys;print(ipaddress.ip_interface(sys.argv[1]).network.network_address+2)" "$GW_CIDR")
NS=ns-dhcp-vlan$VLAN; GWIF=gw_vlan$VLAN; VH=vh_vlan$VLAN; VN=vn_vlan$VLAN

# 1) Gateway de la VLAN: puerto interno del OvS con tag
ovs-vsctl --may-exist add-port "$OVS" "$GWIF" tag="$VLAN" -- set interface "$GWIF" type=internal
ip addr replace "$GW_CIDR" dev "$GWIF"
ip link set "$GWIF" up

# 2) Namespace DHCP conectado al OvS con veth (extremo del host con tag)
ip netns add "$NS" 2>/dev/null || true
ip link show "$VH" >/dev/null 2>&1 || ip link add "$VH" type veth peer name "$VN"
ip link set "$VN" netns "$NS" 2>/dev/null || true
ovs-vsctl --may-exist add-port "$OVS" "$VH" tag="$VLAN"
ip link set "$VH" up
ip netns exec "$NS" ip link set lo up
ip netns exec "$NS" ip addr replace "$DHCP_IP/$PREFIX" dev "$VN"
ip netns exec "$NS" ip link set "$VN" up

# 3) dnsmasq dentro del namespace (gateway y DNS entregados por DHCP)
PID=/var/run/dnsmasq-vlan$VLAN.pid
[ -f "$PID" ] && kill "$(cat $PID)" 2>/dev/null || true
ip netns exec "$NS" dnsmasq --interface="$VN" --bind-interfaces \
  --dhcp-range="$RANGE,$MASK,12h" --dhcp-option=3,"$GW" --dhcp-option=6,8.8.8.8 \
  --pid-file="$PID" --dhcp-leasefile=/var/lib/misc/dnsmasq-vlan$VLAN.leases

echo "[OK] Red VLAN $VLAN: gw $GW_CIDR ($GWIF), DHCP $RANGE en $NS ($DHCP_IP)"
