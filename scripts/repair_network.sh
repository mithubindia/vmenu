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

# Función para limpiar la pantalla
clear_screen() {
    if [ "$USE_WHIPTAIL" = false ]; then
        clear
    fi
}

# Detectar si se está ejecutando en la consola física de Proxmox
is_physical_console() {
    if [ "$(tty)" = "/dev/tty1" ] || [ "$(tty)" = "/dev/tty2" ] || [ "$(tty)" = "/dev/tty3" ]; then
        return 0  # Es consola física
    else
        return 1  # No es consola física
    fi
}

# Determinar si se debe usar whiptail
if is_physical_console; then
    USE_WHIPTAIL=false
else
    USE_WHIPTAIL=true
fi

# Funciones de utilidad
error() {
    echo -e "${RED}${NETWORK_ERROR}: $1${NC}"
}

success() {
    echo -e "${GREEN}${NETWORK_SUCCESS}: $1${NC}"
}

warning() {
    echo -e "${YELLOW}${NETWORK_WARNING}: $1${NC}"
}

# Función para detectar interfaces de red físicas
detect_physical_interfaces() {
    physical_interfaces=$(ip -o link show | awk -F': ' '$2 !~ /^(lo|vmbr|bond|dummy)/ {print $2}')
    echo "${NETWORK_PHYSICAL_INTERFACES}: $physical_interfaces"
}

# Función para verificar y corregir la configuración de puentes
check_and_fix_bridges() {
    echo "${NETWORK_CHECKING_BRIDGES}"
    bridges=$(grep "^auto vmbr" /etc/network/interfaces | awk '{print $2}')
    for bridge in $bridges; do
        old_port=$(grep -A1 "iface $bridge" /etc/network/interfaces | grep "bridge-ports" | awk '{print $2}')
        if ! ip link show "$old_port" &>/dev/null; then
            warning "${NETWORK_BRIDGE_PORT_MISSING}: $bridge - $old_port"
            new_port=$(echo "$physical_interfaces" | tr ' ' '\n' | grep -v "vmbr" | head -n1)
            if [ -n "$new_port" ]; then
                sed -i "/iface $bridge/,/bridge-ports/ s/bridge-ports.*/bridge-ports $new_port/" /etc/network/interfaces
                success "${NETWORK_BRIDGE_PORT_UPDATED}: $bridge - $old_port -> $new_port"
            else
                error "${NETWORK_NO_PHYSICAL_INTERFACE}"
            fi
        else
            echo "${NETWORK_BRIDGE_PORT_OK}: $bridge - $old_port"
        fi
    done
}

# Función para limpiar interfaces no existentes
clean_nonexistent_interfaces() {
    echo "${NETWORK_CLEANING_INTERFACES}"
    configured_interfaces=$(grep "^iface" /etc/network/interfaces | awk '{print $2}' | grep -v "lo" | grep -v "vmbr")
    for iface in $configured_interfaces; do
        if ! ip link show "$iface" &>/dev/null; then
            sed -i "/iface $iface/,/^$/d" /etc/network/interfaces
            success "${NETWORK_INTERFACE_REMOVED}: $iface"
        fi
    done
}

# Función para configurar interfaces físicas
configure_physical_interfaces() {
    echo "${NETWORK_CONFIGURING_INTERFACES}"
    for iface in $physical_interfaces; do
        if ! grep -q "iface $iface" /etc/network/interfaces; then
            echo -e "\niface $iface inet manual" >> /etc/network/interfaces
            success "${NETWORK_INTERFACE_ADDED}: $iface"
        fi
    done
}

# Función para reiniciar el servicio de red
restart_networking() {
    echo "${NETWORK_RESTARTING}"
    systemctl restart networking
    if [ $? -eq 0 ]; then
        success "${NETWORK_RESTART_SUCCESS}"
    else
        error "${NETWORK_RESTART_FAILED}"
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
    echo "${NETWORK_IP_INFO}"
    for interface in $physical_interfaces $(grep "^auto vmbr" /etc/network/interfaces | awk '{print $2}'); do
        ip_info=$(ip addr show $interface 2>/dev/null | grep "inet " | awk '{print $2}')
        if [ -n "$ip_info" ]; then
            echo "$interface: $ip_info"
        else
            echo "$interface: ${NETWORK_NO_IP}"
        fi
    done
}

# Función para reparar la red
repair_network() {
    echo "${NETWORK_REPAIR_STARTED}"
    detect_physical_interfaces
    clean_nonexistent_interfaces
    check_and_fix_bridges
    configure_physical_interfaces
    restart_networking
    if check_network_connectivity; then
        show_ip_info
        success "${NETWORK_REPAIR_COMPLETED}"
    else
        error "${NETWORK_REPAIR_FAILED}"
    fi
    echo "${NETWORK_REPAIR_PROCESS_FINISHED}"
}

# Función para verificar la configuración de red
verify_network() {
    echo "${NETWORK_VERIFY_STARTED}"
    detect_physical_interfaces
    show_ip_info
    check_network_connectivity
    echo "${NETWORK_VERIFY_FINISHED}"
}

# Función para mostrar el menú en modo consola
show_console_menu() {
    while true; do
        clear_screen
        echo "${MENU_TITLE}"
        echo "1. ${MENU_REPAIR}"
        echo "2. ${MENU_VERIFY}"
        echo "3. ${MENU_SHOW_IP}"
        echo "4. ${MENU_EXIT}"
        read -p "${MENU_PROMPT}" choice
        case $choice in
            1) repair_network; read -p "${PRESS_ENTER}"; clear_screen ;;
            2) verify_network; read -p "${PRESS_ENTER}"; clear_screen ;;
            3) show_ip_info; read -p "${PRESS_ENTER}"; clear_screen ;;
            4) echo "${MENU_EXIT_MSG}"; return ;;
            *) echo "${INVALID_OPTION}"; sleep 2; clear_screen ;;
        esac
    done
}

# Función para mostrar el menú en modo whiptail
show_whiptail_menu() {
    while true; do
        OPTION=$(whiptail --title "${MENU_TITLE}" --menu "${MENU_PROMPT}" 15 60 4 \
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
                whiptail --title "${RESULT_TITLE}" --msgbox "${REPAIR_COMPLETED}" 8 78
                ;;
            2)
                verify_network
                whiptail --title "${RESULT_TITLE}" --msgbox "${VERIFY_COMPLETED}" 8 78
                ;;
            3)
                show_ip_info
                whiptail --title "${RESULT_TITLE}" --msgbox "${IP_INFO_COMPLETED}" 8 78
                ;;
            4)
                echo "${MENU_EXIT_MSG}"
                return
                clear_screen
                ;;
        esac
    done
}

# Función principal
main() {
    echo "Iniciando script de reparación de red (versión $VERSION)"
    echo "Uso de whiptail: $USE_WHIPTAIL"
    
    if $USE_WHIPTAIL; then
        show_whiptail_menu
    else
        show_console_menu
    fi
}

# Ejecutar la función principal
main
