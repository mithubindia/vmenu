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
# This script automates the configuration and installation of
# Coral TPU and iGPU support in Proxmox VE containers. It:
# - Configures a selected LXC container for hardware acceleration
# - Installs and sets up Coral TPU drivers on the Proxmox host
# - Installs necessary drivers inside the container
# - Manages required system and container restarts
#
# The script aims to simplify the process of enabling
# AI-powered video analysis capabilities in containers
# LXC, leveraging hardware acceleration for
# improved performance.
# ==========================================================

# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache

# ==========================================================


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


# Validate that the selected container is valid
validate_container_id() {
    if [ -z "$CONTAINER_ID" ]; then
        msg_error "$(translate 'Container ID not defined. Make sure to select a container first.')"
        exit 1
    fi

    # Check if the container is running and stop it before configuration
    if pct status "$CONTAINER_ID" | grep -q "running"; then
        msg_info "$(translate 'Stopping the container before applying configuration...')"
        pct stop "$CONTAINER_ID"
        msg_ok "$(translate 'Container stopped.')"
    fi
}


# Configure LXC for Coral TPU and iGPU
configure_lxc_hardware() {
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
    else
        msg_ok "$(translate 'The container is already privileged.')"
    fi

    # Configure iGPU
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

   # Configure Coral TPU (USB and M.2)
    if ! grep -Pq "^lxc.cgroup2.devices.allow: c 189:\* rwm # Coral USB$" "$CONFIG_FILE"; then
        echo "lxc.cgroup2.devices.allow: c 189:* rwm # Coral USB" >> "$CONFIG_FILE"
    fi

    if ! grep -Pq "^lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir$" "$CONFIG_FILE"; then
        echo "lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir" >> "$CONFIG_FILE"
    fi

    if ! grep -Pq "^lxc.mount.entry: /dev/apex_0 dev/apex_0 none bind,optional,create=file$" "$CONFIG_FILE"; then
        echo "lxc.mount.entry: /dev/apex_0 dev/apex_0 none bind,optional,create=file" >> "$CONFIG_FILE"
    fi

    msg_ok "$(translate 'Coral TPU and iGPU configuration added to container') $CONTAINER_ID."
}


# Install Coral TPU drivers in the container
install_coral_in_container() {

    msg_info2 "$(translate 'Installing iGPU and Coral TPU drivers inside the container...')"
    tput sc
    LOG_FILE=$(mktemp)
    
    pct start "$CONTAINER_ID"

    CORAL_M2=$(lspci | grep -i "Global Unichip")
    if [[ -n "$CORAL_M2" ]]; then
        DRIVER_OPTION=$(whiptail --title "$(translate 'Select driver version')" \
            --menu "$(translate 'Choose the driver version for Coral M.2:\n\nCaution: Maximum mode generates more heat.')" 15 60 2 \
            1 "libedgetpu1-std ($(translate 'standard performance'))" \
            2 "libedgetpu1-max ($(translate 'maximum performance'))" 3>&1 1>&2 2>&3)

        case "$DRIVER_OPTION" in
            1) DRIVER_PACKAGE="libedgetpu1-std" ;;
            2) DRIVER_PACKAGE="libedgetpu1-max" ;;
            *) DRIVER_PACKAGE="libedgetpu1-std" ;;
        esac
    else
        DRIVER_PACKAGE="libedgetpu1-std"
    fi

    script -q -c "pct exec \"$CONTAINER_ID\" -- bash -c '
    set -e
    echo \"- Updating package lists...\"
    apt-get update
    echo \"- Installing iGPU drivers...\"
    apt-get install -y va-driver-all ocl-icd-libopencl1 intel-opencl-icd vainfo intel-gpu-tools
    chgrp video /dev/dri && chmod 755 /dev/dri
    adduser root video && adduser root render

    echo \"- Installing Coral TPU dependencies...\"
    apt-get install -y gnupg python3 python3-pip python3-venv

    echo \"- Adding Coral TPU repository...\"
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/coral-edgetpu.gpg
    echo \"deb [signed-by=/usr/share/keyrings/coral-edgetpu.gpg] https://packages.cloud.google.com/apt coral-edgetpu-stable main\" | tee /etc/apt/sources.list.d/coral-edgetpu.list

    echo \"- Updating package lists again...\"
    apt-get update
    echo \"- Installing Coral TPU driver ($DRIVER_PACKAGE)...\"
    apt-get install -y $DRIVER_PACKAGE
    '" "$LOG_FILE"

    if [ $? -eq 0 ]; then
        tput rc  
        tput ed  
        rm -f "$LOG_FILE"  
        msg_ok "$(translate 'iGPU and Coral TPU drivers installed inside the container.')"
    else
        msg_error "$(translate 'Failed to install iGPU and Coral TPU drivers inside the container.')"
        cat "$LOG_FILE"  
        rm -f "$LOG_FILE"
        exit 1
    fi
}



select_container 
configure_lxc_hardware
install_coral_in_container 



msg_ok "$(translate 'Configuration completed.')"
sleep 2
