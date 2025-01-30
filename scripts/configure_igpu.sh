#!/bin/bash

# Variables globales
CHANGES_MADE=0  # Indica si se hicieron cambios en el contenedor

# Colores para salida
YW="\033[33m"
GN="\033[1;92m"
RD="\033[01;31m"
CL="\033[m"

# Funciones auxiliares
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}
msg_info() {
    echo -ne " ${YW}[INFO] $1...${CL}"
}
msg_ok() {
    echo -e " ${GN}[OK] $1${CL}"
}
msg_error() {
    echo -e " ${RD}[ERROR] $1${CL}"
}

# Validar que el contenedor seleccionado es válido
validate_container_id() {
    if [ -z "$CONTAINER_ID" ]; then
        msg_error "ID del contenedor no definido. Asegúrate de seleccionar un contenedor primero."
        exit 1
    fi
}

# Selección del contenedor LXC
select_container() {
    CONTAINERS=$(pct list | awk 'NR>1 {print $1, $3}' | xargs -n2)
    if [ -z "$CONTAINERS" ]; then
        msg_error "No hay contenedores disponibles en Proxmox."
        exit 1
    fi

    CONTAINER_ID=$(whiptail --title "Seleccionar Contenedor" \
        --menu "Selecciona el contenedor LXC:" 15 60 5 $CONTAINERS 3>&1 1>&2 2>&3)

    if [ -z "$CONTAINER_ID" ]; then
        msg_error "No se seleccionó ningún contenedor. Saliendo."
        exit 1
    fi

    msg_ok "Contenedor seleccionado: $CONTAINER_ID"
}

# Configurar iGPU en el contenedor
configure_lxc_for_igpu() {
    validate_container_id
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"

    if ! grep -q "features: nesting=1" "$CONFIG_FILE"; then
        echo "features: nesting=1" >> "$CONFIG_FILE"
    fi

    if ! grep -q "c 226:0 rwm" "$CONFIG_FILE"; then
        echo "lxc.cgroup2.devices.allow: c 226:0 rwm # iGPU" >> "$CONFIG_FILE"
        echo "lxc.cgroup2.devices.allow: c 226:128 rwm # iGPU" >> "$CONFIG_FILE"
        echo "lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir" >> "$CONFIG_FILE"
    fi

    msg_ok "Configuración de iGPU añadida al contenedor $CONTAINER_ID."
}

# Instalar controladores iGPU en el contenedor
install_igpu_in_container() {
    msg_info "Instalando controladores de iGPU dentro del contenedor..."
    pct start "$CONTAINER_ID"
    pct exec "$CONTAINER_ID" -- bash -c "
    apt-get update && \
    apt-get install -y va-driver-all ocl-icd-libopencl1 intel-opencl-icd vainfo intel-gpu-tools && \
    chgrp video /dev/dri && chmod 755 /dev/dri && \
    adduser root video && adduser root render
    "
    msg_ok "Controladores de iGPU instalados dentro del contenedor."
}

# Ejecución
select_container
configure_lxc_for_igpu
install_igpu_in_container
msg_ok "Configuración de iGPU completada en el contenedor $CONTAINER_ID."
