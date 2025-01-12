#!/bin/bash

# Configuración
VERSION="1.0"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
LANGUAGE_FILE="/root/.proxmenux_language"

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Cargar el archivo de idioma
if [ -f "$LANGUAGE_FILE" ]; then
    LANGUAGE=$(cat "$LANGUAGE_FILE")
    LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
    if [ -f "$LANG_FILE" ]; then
        source "$LANG_FILE"
    else
        echo "Error: No se pudo cargar el archivo de idioma $LANG_FILE."
        exit 1
    fi
else
    echo "Error: No se pudo determinar el idioma. Archivo $LANGUAGE_FILE no encontrado."
    exit 1
fi

# Funciones de utilidad
error() {
    whiptail --title "${NETWORK_ERROR}" --msgbox "$1" 8 78
}

success() {
    whiptail --title "${NETWORK_SUCCESS}" --msgbox "$1" 8 78
}

warning() {
    whiptail --title "${NETWORK_WARNING}" --msgbox "$1" 8 78
}

# Función para detectar interfaces de red físicas
detect_physical_interfaces() {
    physical_interfaces=$(ip -o link show | awk -F': ' '$2 !~ /^(lo|vmbr|bond|dummy)/ {print $2}')
    whiptail --title "${NETWORK_PHYSICAL_INTERFACES}" --msgbox "$physical_interfaces" 10 78
}

# Función para verificar y corregir la configuración de puentes
check_and_fix_bridges() {
    local output=""
    output+="${NETWORK_CHECKING_BRIDGES}\n\n"
    bridges=$(grep "^auto vmbr" /etc/network/interfaces | awk '{print $2}')
    for bridge in $bridges; do
        old_port=$(grep -A1 "iface $bridge" /etc/network/interfaces | grep "bridge-ports" | awk '{print $2}')
        if ! ip link show "$old_port" &>/dev/null; then
            output+="${NETWORK_BRIDGE_PORT_MISSING}: $bridge - $old_port\n"
            new_port=$(echo "$physical_interfaces" | tr ' ' '\n' | grep -v "vmbr" | head -n1)
            if [ -n "$new_port" ]; then
                sed -i "/iface $bridge/,/bridge-ports/ s/bridge-ports.*/bridge-ports $new_port/" /etc/network/interfaces
                output+="${NETWORK_BRIDGE_PORT_UPDATED}: $bridge - $old_port -> $new_port\n"
            else
                output+="${NETWORK_NO_PHYSICAL_INTERFACE}\n"
            fi
        else
            output+="${NETWORK_BRIDGE_PORT_OK}: $bridge - $old_port\n"
        fi
    done
    whiptail --title "${NETWORK_CHECKING_BRIDGES}" --msgbox "$output" 20 78
}

# Función para limpiar interfaces no existentes
clean_nonexistent_interfaces() {
    local output=""
    output+="${NETWORK_CLEANING_INTERFACES}\n\n"
    configured_interfaces=$(grep "^iface" /etc/network/interfaces | awk '{print $2}' | grep -v "lo" | grep -v "vmbr")
    for iface in $configured_interfaces; do
        if ! ip link show "$iface" &>/dev/null; then
            sed -i "/iface $iface/,/^$/d" /etc/network/interfaces
            output+="${NETWORK_INTERFACE_REMOVED}: $iface\n"
        fi
    done
    whiptail --title "${NETWORK_CLEANING_INTERFACES}" --msgbox "$output" 15 78
}

# Función para configurar interfaces físicas
configure_physical_interfaces() {
    local output=""
    output+="${NETWORK_CONFIGURING_INTERFACES}\n\n"
    for iface in $physical_interfaces; do
        if ! grep -q "iface $iface" /etc/network/interfaces; then
            echo -e "\niface $iface inet manual" >> /etc/network/interfaces
            output+="${NETWORK_INTERFACE_ADDED}: $iface\n"
        fi
    done
    whiptail --title "${NETWORK_CONFIGURING_INTERFACES}" --msgbox "$output" 15 78
}

# Función para reiniciar el servicio de red
restart_networking() {
    if (whiptail --title "${NETWORK_RESTARTING}" --yesno "${NETWORK_RESTART_CONFIRM}" 10 60); then
        systemctl restart networking
        if [ $? -eq 0 ]; then
            success "${NETWORK_RESTART_SUCCESS}"
        else
            error "${NETWORK_RESTART_FAILED}"
        fi
    else
        warning "${NETWORK_RESTART_CANCELED}"
    fi
}

# Función para verificar la conectividad de red
check_network_connectivity() {
    if ping -c 4 8.8.8.8 &> /dev/null; then
        success "${NETWORK_CONNECTIVITY_OK}"
        return 0
    else
        warning "${NETWORK_CONNECTIVITY_FAILED}"
        return 1
    fi
}

# Función para mostrar información de IP
show_ip_info() {
    whiptail --title "${NETWORK_IP_INFO}" --infobox "${NETWORK_IP_INFO_RUNNING}" 8 78
    local ip_info=""
    ip_info+="${NETWORK_IP_INFO}\n\n"
    for interface in $physical_interfaces $(grep "^auto vmbr" /etc/network/interfaces | awk '{print $2}'); do
        local interface_ip=$(ip addr show $interface 2>/dev/null | grep "inet " | awk '{print $2}')
        if [ -n "$interface_ip" ]; then
            ip_info+="$interface: $interface_ip\n"
        else
            ip_info+="$interface: ${NETWORK_NO_IP}\n"
        fi
    done
    whiptail --title "${RESULT_TITLE}" --msgbox "${ip_info}\n\n${IP_INFO_COMPLETED}\n\n${PRESS_ENTER}" 20 78
}

# Función para reparar la red
repair_network() {
    whiptail --title "${NETWORK_REPAIR_STARTED}" --infobox "${NETWORK_REPAIR_RUNNING}" 8 78
    detect_physical_interfaces
    clean_nonexistent_interfaces
    check_and_fix_bridges
    configure_physical_interfaces
    restart_networking
    if check_network_connectivity; then
        show_ip_info
        success "${NETWORK_REPAIR_SUCCESS}"
    else
        error "${NETWORK_REPAIR_ERROR}"
    fi
    whiptail --title "${RESULT_TITLE}" --msgbox "${REPAIR_COMPLETED}\n\n${PRESS_ENTER}" 10 78
}

# Función para verificar la configuración de red
verify_network() {
    whiptail --title "${NETWORK_VERIFY_STARTED}" --infobox "${NETWORK_VERIFY_RUNNING}" 8 78
    detect_physical_interfaces
    show_ip_info
    if check_network_connectivity; then
        success "${NETWORK_VERIFY_SUCCESS}"
    else
        error "${NETWORK_VERIFY_ERROR}"
    fi
    whiptail --title "${RESULT_TITLE}" --msgbox "${VERIFY_COMPLETED}\n\n${PRESS_ENTER}" 10 78
}

# Función para mostrar el menú principal
show_main_menu() {
    while true; do
        OPTION=$(whiptail --title "${REPAIR_MENU_TITLE}" --menu "${MENU_PROMPT}" 15 60 4 \
        "1" "${MENU_REPAIR}" \
        "2" "${MENU_VERIFY}" \
        "3" "${MENU_SHOW_IP}" \
        "4" "${MENU_EXIT}" 3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
            echo "${MENU_CANCELED}"
            exit
        fi

        case $OPTION in
            1)
                repair_network
                ;;
            2)
                verify_network
                ;;
            3)
                show_ip_info
                ;;
            4)
                echo "${MENU_EXIT_MSG}"
                return
                ;;
        esac
    done
}

# Función principal
main() {
    show_main_menu
}

# Ejecutar la función principal
main
