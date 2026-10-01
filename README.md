# TEL141_L4_20222297
Laboratorio 4 – TEL141: automatización de orquestación/aprovisionamiento de un slice de VMs.

## Informe previo (raíz)
| Script | Nodo | Uso |
|---|---|---|
| init_master.sh | Head Node | `init_master.sh <iface...>` |
| create_network_vlan.sh | Head Node | `create_network_vlan.sh <VLAN> <red_CIDR> <on\|off> [inicio,fin]` |
| internet_to_network.sh | Head Node | `internet_to_network.sh <VLAN> <red_CIDR>` |
| no_internet_to_network.sh | Head Node | `no_internet_to_network.sh <VLAN> <red_CIDR>` |
| routing_networks.sh | Head Node | `routing_networks.sh <VLAN1> <VLAN2>` |
| no_routing_networks.sh | Head Node | `no_routing_networks.sh <VLAN1> <VLAN2>` |
| init_worker.sh | Cómputo | `init_worker.sh <iface...>` |
| create_vm.sh | Cómputo | `create_vm.sh <VM> <OVS> <VLAN> <puerto_VNC>` |
| delete_vm.sh | Cómputo | `delete_vm.sh <VM> <OVS> <VLAN> <puerto_VNC>` |

## Reporte final
`DEV/actividad_X/actividad_X.sh`: scripts principales ejecutados desde Server 4.
