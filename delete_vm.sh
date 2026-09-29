#!/bin/bash
# Uso: ./delete_vm.sh <nombre_VM> <nombre_OvS>
# Detiene la VM y elimina su interfaz TAP del OvS y del sistema.
[ $# -ne 2 ] && { echo "Uso: $0 <VM> <OvS>"; exit 1; }
VM=$1; OVS=$2; TAP=tap_${VM:0:11}
pkill -f "qemu-system-x86_64 -name $VM " && echo "VM $VM detenida" || echo "VM $VM no estaba corriendo"
ovs-vsctl --if-exists del-port "$OVS" "$TAP"
ip link del "$TAP" 2>/dev/null
echo "[OK] VM $VM eliminada"
