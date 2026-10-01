#!/bin/bash
# ACTIVIDAD 3: redes aisladas CON DHCP y SIN salida a Internet
# Se ejecuta desde Server 4 (Cliente). Usa los scripts del informe previo.
DIR="$(cd "$(dirname "$0")/.." && pwd)"
USR=ubuntu
HEAD=10.0.10.3   # Server 3: Head Node
W1=10.0.10.1     # Server 1: contenedores
W2=10.0.10.2     # Server 2: VMs
IF=ens4
NET100=192.168.0.0/24; NET200=192.168.2.0/24

# run <ip> <script> [args]: ejecuta un script del previo en el nodo remoto con sudo
run() { local H=$1 S=$2; shift 2; echo ">>> [$H] $S $*"
  ssh -o StrictHostKeyChecking=no $USR@$H 'sudo bash -s' < "$DIR/$S" "$@"; }

# cont <nombre> <VLAN> <dhcp|IP/pref> [gw]: contenedor (namespace + veth) en Server 1
cont() { echo ">>> [$W1] contenedor $1 VLAN $2 ($3)"
  ssh -o StrictHostKeyChecking=no $USR@$W1 "sudo bash -s" <<EOS
ip netns add $1; mkdir -p /etc/netns/$1; echo 'nameserver 8.8.8.8' > /etc/netns/$1/resolv.conf
ip link add v$1-o type veth peer name v$1-c; ip link set v$1-c netns $1
ovs-vsctl add-port br-int v$1-o tag=$2; ip link set v$1-o up
ip netns exec $1 ip link set lo up; ip netns exec $1 ip link set v$1-c up
if [ "$3" = dhcp ]; then ip netns exec $1 dhclient -1 v$1-c; else ip netns exec $1 ip addr add $3 dev v$1-c; ip netns exec $1 ip route add default via $4; fi
ip netns exec $1 ip -4 -o addr show v$1-c
EOS
}

# limpieza del despliegue anterior
limpiar() { echo ">>> Limpiando despliegue anterior"
  run $W2 delete_vm.sh vm100 br-int 100 5901 >/dev/null
  run $W2 delete_vm.sh vm200 br-int 200 5902 >/dev/null
  ssh $USR@$W1 'for c in c100 c200; do sudo ovs-vsctl --if-exists del-port br-int v$c-o; sudo ip link del v$c-o; sudo ip netns pids $c | xargs -r sudo kill; sudo ip netns del $c; done' 2>/dev/null
  run $HEAD no_routing_networks.sh 100 200 >/dev/null
  run $HEAD no_internet_to_network.sh 100 $NET100 >/dev/null
  run $HEAD no_internet_to_network.sh 200 $NET200 >/dev/null
  ssh $USR@$HEAD 'for v in 100 200; do sudo pkill -f "dnsmasq.*dhcp_vlan$v"; sudo ovs-vsctl --if-exists del-port br-int gw_vlan$v -- --if-exists del-port br-int dhcp_vlan$v; sudo ip netns del ns-dhcp-vlan$v; done' 2>/dev/null
}

limpiar
run $HEAD init_master.sh $IF
run $HEAD create_network_vlan.sh 100 $NET100 on 192.168.0.10,192.168.0.100
run $HEAD create_network_vlan.sh 200 $NET200 on 192.168.2.10,192.168.2.100
run $HEAD no_internet_to_network.sh 100 $NET100
run $HEAD no_internet_to_network.sh 200 $NET200
run $W1 init_worker.sh $IF
cont c100 100 dhcp
cont c200 200 dhcp
run $W2 init_worker.sh $IF
run $W2 create_vm.sh vm100 br-int 100 5901
run $W2 create_vm.sh vm200 br-int 200 5902
echo "=== Actividad 3 desplegada ==="
