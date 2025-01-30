#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 28/01/2025
# ==========================================================


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
CONFIG_FILE="$BASE_DIR/config.json"
VENV_PATH="/opt/googletrans-env"

if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi

initialize_cache() {
    if [ ! -f "$CACHE_FILE" ]; then
        echo "{}" > "$CACHE_FILE"
        return
    fi
}

load_language() {
    if [ -f "$CONFIG_FILE" ]; then
        LANGUAGE=$(jq -r '.language' "$CONFIG_FILE")
    fi
}

# ==========================================================



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

    if ! pct list | awk 'NR>1 {print $1}' | grep -qw "$CONTAINER_ID"; then
        msg_error "El contenedor con ID $CONTAINER_ID no existe. Saliendo."
        exit 1
    fi

    msg_ok "Contenedor seleccionado: $CONTAINER_ID"
}

# Validar y cambiar a privilegiado si es necesario
ensure_privileged_container() {
    validate_container_id
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"
    if [ ! -f "$CONFIG_FILE" ]; then
        msg_error "Archivo de configuración del contenedor $CONTAINER_ID no encontrado."
        exit 1
    fi

    if grep -q "^unprivileged: 1" "$CONFIG_FILE"; then
        msg_info "El contenedor es no privilegiado. Cambiando a privilegiado..."
        sed -i "s/^unprivileged: 1/unprivileged: 0/" "$CONFIG_FILE"
        STORAGE_TYPE=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk -F, '{print $2}' | cut -d'=' -f2)
        if [[ "$STORAGE_TYPE" == "dir" ]]; then
            STORAGE_PATH=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk '{print $2}' | cut -d',' -f1)
            chown -R root:root "$STORAGE_PATH"
        fi
        msg_ok "Contenedor cambiado a privilegiado."
    fi
}

# Configurar iGPU en el contenedor
configure_lxc_for_igpu() {
    ensure_privileged_container
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"

    if ! grep -q "features: nesting=1" "$CONFIG_FILE"; then
        echo "features: nesting=1" >> "$CONFIG_FILE"
    fi

    if ! grep -q "c 226:0 rwm" "$CONFIG_FILE"; then
        echo "lxc.cgroup2.devices.allow: c 226:0 rwm # iGPU" >> "$CONFIG_FILE"
        echo "lxc.cgroup2.devices.allow: c 226:128 rwm # iGPU" >> "$CONFIG_FILE"
        echo "lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir" >> "$CONFIG_FILE"
        echo "lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file" >> "$CONFIG_FILE"
    fi

    if ! grep -q "c 29:0 rwm # Framebuffer" "$CONFIG_FILE"; then
        echo "lxc.cgroup2.devices.allow: c 29:0 rwm # Framebuffer" >> "$CONFIG_FILE"
    fi

    if ! grep -q "lxc.mount.entry: /dev/fb0" "$CONFIG_FILE"; then
        echo "lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file" >> "$CONFIG_FILE"
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
