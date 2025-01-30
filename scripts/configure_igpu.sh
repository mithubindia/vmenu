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
# Description:
# This script automates the process of enabling and configuring
# Intel integrated GPU (iGPU) support in Proxmox VE LXC containers.
# It performs the following main tasks:
# - Selects a target LXC container
# - Ensures the container is set to privileged mode
# - Configures the LXC container for iGPU passthrough
# - Installs necessary iGPU drivers and tools inside the container
# - Manages container restarts as needed
#
# The script aims to simplify the setup of hardware-accelerated
# graphics capabilities in LXC containers, enabling efficient
# use of Intel iGPUs for tasks such as transcoding, rendering,
# and accelerating graphics-intensive applications.
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


# Validar que el contenedor seleccionado es válido
validate_container_id() {
    if [ -z "$CONTAINER_ID" ]; then
        msg_error "ID del contenedor no definido. Asegúrate de seleccionar un contenedor primero."
        exit 1
    fi
}


# Select LXC container
select_container() {
    CONTAINERS=$(pct list | awk 'NR>1 {print $1, $3}' | xargs -n2)
    if [ -z "$CONTAINERS" ]; then
        msg_error "$(translate 'No containers available in Proxmox.')"
        exit 1
    fi

    CONTAINER_ID=$(whiptail --title "$(translate 'Select Container')" \
        --menu "$(translate 'Select the LXC container:')" 15 60 5 $CONTAINERS 3>&1 1>&2 2>&3)

    if [ -z "$CONTAINER_ID" ]; then
        msg_error "$(translate 'No container selected. Exiting.')"
        exit 1
    fi

    if ! pct list | awk 'NR>1 {print $1}' | grep -qw "$CONTAINER_ID"; then
        msg_error "$(translate 'Container with ID') $CONTAINER_ID $(translate 'does not exist. Exiting.')"
        exit 1
    fi

    msg_ok "$(translate 'Container selected:') $CONTAINER_ID"
}

# Validate and change to privileged if necessary
ensure_privileged_container() {
    validate_container_id
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"
    if [ ! -f "$CONFIG_FILE" ]; then
        msg_error "$(translate 'Configuration file for container') $CONTAINER_ID $(translate 'not found.')"
        exit 1
    fi

    if grep -q "^unprivileged: 1" "$CONFIG_FILE"; then
        msg_info "$(translate 'The container is unprivileged. Changing to privileged...')"
        sed -i "s/^unprivileged: 1/unprivileged: 0/" "$CONFIG_FILE"
        STORAGE_TYPE=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk -F, '{print $2}' | cut -d'=' -f2)
        if [[ "$STORAGE_TYPE" == "dir" ]]; then
            STORAGE_PATH=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk '{print $2}' | cut -d',' -f1)
            chown -R root:root "$STORAGE_PATH"
        fi
        msg_ok "$(translate 'Container changed to privileged.')"
    fi
}

# Configure iGPU in the container
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

    msg_ok "$(translate 'iGPU configuration added to container') $CONTAINER_ID."
}

# Install iGPU drivers in the container
install_igpu_in_container() {
    echo -ne "\r${TAB}${YW}-$(translate 'Installing iGPU drivers inside the container...') ${CL}"
    pct start "$CONTAINER_ID"
    pct exec "$CONTAINER_ID" -- bash -c "
    apt-get update && \
    apt-get install -y va-driver-all ocl-icd-libopencl1 intel-opencl-icd vainfo intel-gpu-tools && \
    chgrp video /dev/dri && chmod 755 /dev/dri && \
    adduser root video && adduser root render
    "
    msg_ok "$(translate 'iGPU drivers installed inside the container.')"
}

# Execution
select_container
configure_lxc_for_igpu
install_igpu_in_container
msg_ok "$(translate 'iGPU configuration completed in container') $CONTAINER_ID."
