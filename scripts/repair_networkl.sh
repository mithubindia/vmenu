#!/bin/bash

# Configuración
SCRIPT_VERSION="1.5"
LOG_FILE="/var/log/repair_network.log"

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Cargar el archivo de idioma
if [ -f "/usr/local/bin/ProxMenux/lang/es.lang" ]; then
    source "/usr/local/bin/ProxMenux/lang/es.lang"
else
    echo "Error: No se pudo cargar el archivo de idioma."
    exit 1
fi

# Funciones de utilidad
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

error() {
    log "${RED}${NETWORK_ERROR}: $1${NC}"
}

success() {
    log "${GREEN}${NETWORK_SUCCESS}: $1${NC}"
}

warning() {
    log "${YELLOW}${NETWORK_WARNING}: $1${NC}"
}

# Función para detectar todas las interfaces de red
detect_all_interfaces() {
    all_interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
    physical_interfaces=$(echo "$all_interfaces" | grep -v @)
    vlan_interfaces=$(echo "$all_interfaces" | grep @)
    log "$NETWORK_ALL_INTERFACES: $all_interfaces"
    log "$NETWORK_PHYSICAL_INTERFACES: $physical_interfaces"
    log "$NETWORK_VLAN_INTERFACES: $vlan_interfaces"
}

# Función para obtener interfaces configuradas
get_configured_interfaces() {
    configured_interfaces=$(grep -E "^auto|^allow-hotplug" /etc/network/interfaces | awk '{print $2}' | sort | uniq)
    log "$NETWORK_CONFIGURED_INTERFACES: $configured_interfaces"
}

# Función para verificar y corregir la configuración de VLANs
check_and_fix_vlans() {
    for vlan in $vlan_interfaces; do
        local parent_interface=$(echo $vlan | cut -d@ -f2)
        local vlan_id=$(echo $vlan | cut -d. -f2)
        
        if ! grep -q "^auto $vlan" /etc/network/interfaces; then
            log "$NETWORK_VLAN_NOT_CONFIGURED: $vlan"
            configure_vlan $vlan
        else
            local configured_parent=$(grep -A2 "iface $vlan" /etc/network/interfaces | grep "vlan-raw-device" | awk '{print $2}')
            local configured_id=$(grep -A2 "iface $vlan" /etc/network/interfaces | grep "vlan_id" | awk '{print $2}')
            
            if [ "$configured_parent" != "$parent_interface" ] || [ "$configured_id" != "$vlan_id" ]; then
                log "$NETWORK_VLAN_MISMATCH: $vlan"
                fix_vlan_config $vlan $parent_interface $vlan_id
            fi
        fi
    done
}

# Función para configurar una VLAN
configure_vlan() {
    local vlan=$1
    local parent_interface=$(echo $vlan | cut -d@ -f2)
    local vlan_id=$(echo $vlan | cut -d. -f2)
    
    echo -e "\nauto $vlan\niface $vlan inet manual\n    vlan-raw-device $parent_interface\n    vlan_id $vlan_id" >> /etc/network/interfaces
    log "$NETWORK_VLAN_CONFIGURED: $vlan"
}

# Función para corregir la configuración de una VLAN
fix_vlan_config() {
    local vlan=$1
    local parent_interface=$2
    local vlan_id=$3
    
    sed -i "/iface $vlan/,/^$/ s/vlan-raw-device.*/vlan-raw-device $parent_interface/" /etc/network/interfaces
    sed -i "/iface $vlan/,/^$/ s/vlan_id.*/vlan_id $vlan_id/" /etc/network/interfaces
    log "$NETWORK_VLAN_FIXED: $vlan"
}

# Función para verificar y corregir la configuración de puentes
check_and_fix_bridge_ports() {
    local bridge=$1
    local old_port=$(grep "bridge-ports" /etc/network/interfaces | grep $bridge | awk '{print $2}')
    
    if ! ip link show $old_port &>/dev/null; then
        log "$NETWORK_BRIDGE_PORT_MISSING: $bridge - $old_port"
        
        local candidates=$(ip -o link show | awk -F': ' '$2 !~ /^(lo|vmbr|bond|dummy)/ {print $2}')
        
        echo "$NETWORK_SELECT_NEW_BRIDGE_PORT: $bridge"
        echo "$NETWORK_AVAILABLE_INTERFACES:"
        
        local i=1
        for iface in $candidates; do
            local state=$(cat /sys/class/net/$iface/operstate)
            local ip_addr=$(ip -o -4 addr show dev $iface | awk '{print $4}')
            local config_type=$(grep -A1 "iface $iface" /etc/network/interfaces | grep -q "dhcp" && echo "dhcp" || echo "static")
            local vlan=""
            if [[ $iface == *@* ]]; then
                vlan=" (VLAN)"
            fi
            
            if [ -z "$ip_addr" ]; then
                ip_addr="No IP"
            fi
            
            echo "$i) $iface$vlan - Estado: $state, IP: $ip_addr, Configuración: $config_type"
            ((i++))
        done
        
        read -p "$NETWORK_SELECT_INTERFACE: " selection
        
        if [[ $selection =~ ^[0-9]+$ ]] && [ $selection -le $i ]; then
            local new_port=$(echo "$candidates" | sed -n "${selection}p")
            sed -i "s/bridge-ports $old_port/bridge-ports $new_port/" /etc/network/interfaces
            log "$NETWORK_BRIDGE_PORT_UPDATED: $bridge - $old_port -> $new_port"
        else
            log "$NETWORK_BRIDGE_PORT_UPDATE_FAILED: $bridge"
        fi
    fi
}

# Función para reiniciar el servicio de red
restart_networking() {
    log "$NETWORK_RESTARTING"
    systemctl restart networking
    if [ $? -eq 0 ]; then
        success "$NETWORK_RESTART_SUCCESS"
    else
        error "$NETWORK_RESTART_FAILED"
    fi
}

# Función para verificar la conectividad de red
check_network_connectivity() {
    if ping -c 4 8.8.8.8 &> /dev/null; then
        success "$NETWORK_CONNECTIVITY_OK"
        return 0
    else
        warning "$NETWORK_CONNECTIVITY_FAILED"
        return 1
    fi
}

# Función para configurar manualmente una interfaz
configure_interface_manually() {
    local interface=$1
    local current_ip=$(grep -A2 "iface $interface" /etc/network/interfaces | grep "address" | awk '{print $2}')
    local current_gateway=$(grep -A4 "iface $interface" /etc/network/interfaces | grep "gateway" | awk '{print $2}')

    echo "Configurando $interface:"
    echo "Dirección IP actual: $current_ip"
    read -p "¿Desea cambiar la dirección IP? (s/n): " change_ip
    if [[ $change_ip =~ ^[Ss]$ ]]; then
        read -p "Nueva dirección IP: " new_ip
        sed -i "/iface $interface/,/^$/ s/address.*/address $new_ip/" /etc/network/interfaces
    fi

    echo "Puerta de enlace actual: $current_gateway"
    read -p "¿Desea cambiar la puerta de enlace? (s/n): " change_gateway
    if [[ $change_gateway =~ ^[Ss]$ ]]; then
        read -p "Nueva puerta de enlace: " new_gateway
        sed -i "/iface $interface/,/^$/ s/gateway.*/gateway $new_gateway/" /etc/network/interfaces
    fi

    if [[ $interface == *@* ]]; then
        local parent_interface=$(echo $interface | cut -d@ -f2)
        local vlan_id=$(echo $interface | cut -d. -f2)
        echo "Configuración de VLAN:"
        echo "Interfaz padre actual: $parent_interface"
        echo "ID de VLAN actual: $vlan_id"
        read -p "¿Desea cambiar la configuración de VLAN? (s/n): " change_vlan
        if [[ $change_vlan =~ ^[Ss]$ ]]; then
            read -p "Nueva interfaz padre: " new_parent
            read -p "Nuevo ID de VLAN: " new_vlan_id
            sed -i "/iface $interface/,/^$/ s/vlan-raw-device.*/vlan-raw-device $new_parent/" /etc/network/interfaces
            sed -i "/iface $interface/,/^$/ s/vlan_id.*/vlan_id $new_vlan_id/" /etc/network/interfaces
        fi
    fi

    log "$NETWORK_INTERFACE_MANUALLY_CONFIGURED: $interface"
}

# Función para actualizar la IP de Proxmox
update_proxmox_ip() {
    local main_interface=$(ip route | grep default | awk '{print $5}')
    local main_ip=$(ip addr show $main_interface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    if [ -n "$main_ip" ]; then
        sed -i "s/^IP_ADDRESS=.*/IP_ADDRESS=\"$main_ip\"/" /etc/pve/storage.cfg
        log "$PROXMOX_IP_UPDATED: $main_ip"
    else
        warning "$PROXMOX_IP_UPDATE_FAILED"
    fi
}

# Función principal
main() {
    log "$NETWORK_REPAIR_STARTED"
    
    detect_all_interfaces
    get_configured_interfaces

    check_and_fix_vlans

    for bridge in $(grep "iface.*inet static" /etc/network/interfaces | awk '{print $2}'); do
        check_and_fix_bridge_ports $bridge
    done

    update_proxmox_ip
    restart_networking

    if ! check_network_connectivity; then
        read -p "$NETWORK_MANUAL_CONFIG_PROMPT (s/n): " manual_config
        if [[ $manual_config =~ ^[Ss]$ ]]; then
            for interface in $(grep "iface.*inet" /etc/network/interfaces | awk '{print $2}'); do
                configure_interface_manually $interface
            done
            restart_networking
            check_network_connectivity
        fi
    fi
    
    log "$NETWORK_REPAIR_COMPLETED"
}

# Ejecutar la función principal
main
