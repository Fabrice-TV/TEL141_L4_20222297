#!/bin/bash
# Uso: create_vm.sh <nombre_VM> <nombre_OVS> <VLAN_ID> <puerto_VNC>
# Imagen base CirrOS (se descarga si no existe) + disco delta qcow2 por VM.
[ $# -ne 4 ] && { echo "Uso: $0 <VM> <OVS> <VLAN_ID> <puerto_VNC>"; exit 1; }
VM=$1; OVS=$2; VLAN=$3; VNC=$4
DIR=/var/lib/tel141; BASE=$DIR/images/cirros-0.5.1-x86_64-disk.img
URL=https://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
DELTA=$DIR/vms/$VM.qcow2; TAP=tap-${VM:0:11}
MAC=$(printf '20:22:22:97:%02x:%02x' $((VLAN % 256)) $((VNC % 256)))
mkdir -p $DIR/images $DIR/vms

if [ ! -f $BASE ]; then
  echo "Imagen base no encontrada, descargando..."
  wget -q -O $BASE $URL || { echo "Error descargando imagen"; rm -f $BASE; exit 1; }
fi
[ -f $DELTA ] || qemu-img create -f qcow2 -F qcow2 -b $BASE $DELTA >/dev/null

ip tuntap add mode tap name $TAP 2>/dev/null || true
ip link set $TAP up
ovs-vsctl --may-exist add-port $OVS $TAP tag=$VLAN

KVM=""; [ -e /dev/kvm ] && KVM="-enable-kvm"
qemu-system-x86_64 $KVM -name $VM -m 256 -hda $DELTA \
  -netdev tap,id=$TAP,ifname=$TAP,script=no,downscript=no \
  -device e1000,netdev=$TAP,mac=$MAC \
  -vnc 0.0.0.0:$((VNC - 5900)) -daemonize >/dev/null 2>&1 \
  && echo "[OK] VM $VM: VLAN $VLAN, $TAP, MAC $MAC, VNC $VNC" \
  || { echo "Error iniciando $VM"; exit 1; }
