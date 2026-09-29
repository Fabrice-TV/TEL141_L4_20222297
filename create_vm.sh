#!/bin/bash
# Uso: ./create_vm.sh <nombre_VM> <nombre_OvS> <VLAN_ID> <puerto_VNC> [MAC]
# Ej:  ./create_vm.sh vm1 br-int 100 5901
# Crea una interfaz TAP con tag VLAN en el OvS y lanza una VM CirrOS (QEMU) conectada a ella.
set -e
[ $# -lt 4 ] && { echo "Uso: $0 <VM> <OvS> <VLAN_ID> <puerto_VNC> [MAC]"; exit 1; }
VM=$1; OVS=$2; VLAN=$3; VNC=$4
IMG=${IMG:-/root/cirros-0.5.1-x86_64-disk.img}
TAP=tap_${VM:0:11}
# MAC por defecto: prefijo del codigo PUCP 20222297 + ultimo byte aleatorio
MAC=${5:-$(printf '20:22:22:97:%02x:%02x' $((VLAN % 256)) $((RANDOM % 256)))}
DISPLAY_N=$((VNC - 5900))

ip tuntap add mode tap name "$TAP" 2>/dev/null || true
ip link set "$TAP" up
ovs-vsctl --may-exist add-port "$OVS" "$TAP" tag="$VLAN"

qemu-system-x86_64 -name "$VM" -m 256 -snapshot -hda "$IMG" \
  -netdev tap,id="$TAP",ifname="$TAP",script=no,downscript=no \
  -device e1000,netdev="$TAP",mac="$MAC" \
  -vnc 0.0.0.0:"$DISPLAY_N" -daemonize

echo "[OK] VM $VM creada: VLAN $VLAN, TAP $TAP, MAC $MAC, VNC $VNC"
