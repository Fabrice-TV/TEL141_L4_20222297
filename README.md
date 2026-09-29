# TEL141_L4_20222297
Laboratorio 4 – TEL141: automatización de orquestación/aprovisionamiento de un slice de VMs.

| Script | Nodo | Uso |
|---|---|---|
| init_master.sh | Headnode | `./init_master.sh <OvS> <iface...>` |
| create_network_vlan.sh | Headnode | `./create_network_vlan.sh <OvS> <VLAN> <IP_gw/pref> <ini,fin>` |
| internet_to_network.sh | Headnode | `./internet_to_network.sh <VLAN> <iface_internet>` |
| no_internet_to_network.sh | Headnode | `./no_internet_to_network.sh <VLAN> <iface_internet>` |
| routing_networks.sh | Headnode | `./routing_networks.sh <VLAN_A> <VLAN_B>` |
| no_routing_networks.sh | Headnode | `./no_routing_networks.sh <VLAN_A> <VLAN_B>` |
| init_worker.sh | Worker | `./init_worker.sh <OvS> <iface...>` |
| create_vm.sh | Worker | `./create_vm.sh <VM> <OvS> <VLAN> <puerto_VNC> [MAC]` |
| delete_vm.sh | Worker | `./delete_vm.sh <VM> <OvS>` |

Todos se ejecutan como root (`sudo`).
