#!/bin/bash
# Uso: delete_vm.sh <nombre_VM> <nombre_OVS> <VLAN_ID> <puerto_VNC>
# Elimina VM, TAP y disco delta; si la imagen base queda sin deltas, la elimina.
[ $# -ne 4 ] && { echo "Uso: $0 <VM> <OVS> <VLAN_ID> <puerto_VNC>"; exit 1; }
VM=$1; OVS=$2; VLAN=$3; VNC=$4
DIR=/var/lib/tel141; BASE=$DIR/images/cirros-0.5.1-x86_64-disk.img
TAP=tap-${VM:0:11}
pkill -f "qemu-system-x86_64.* -name $VM .*-vnc 0.0.0.0:$((VNC - 5900))" && sleep 1
ovs-vsctl --if-exists del-port $OVS $TAP
ip link del $TAP 2>/dev/null
rm -f $DIR/vms/$VM.qcow2
echo "[OK] VM $VM eliminada (VLAN $VLAN, VNC $VNC)"

USERS=0
for D in $DIR/vms/*.qcow2; do
  [ -f "$D" ] && qemu-img info -U "$D" | grep -q "backing file: $BASE" && USERS=$((USERS+1))
done
if [ $USERS -eq 0 ] && [ -f $BASE ]; then
  rm -f $BASE; echo "[OK] Imagen base sin deltas: eliminada"
else
  echo "[i] Imagen base aun usada por $USERS VM(s)"
fi
