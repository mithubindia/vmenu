#!/bin/bash

# Funciones y colores
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Validaciones
validate_pve_version() {
    if ! pveversion | grep -Eq "pve-manager/(8\\.[0-9]+)"; then
        msg_error "Se requiere Proxmox VE 8.0 o superior."
        exit 1
    fi
}

select_container() {
    CONTAINERS=$(pct list | awk 'NR>1 {print $1, $3}' | xargs -n2)
    CONTAINER_ID=$(whiptail --title "Seleccionar Contenedor" --menu "Selecciona un contenedor LXC:" 15 60 5 $CONTAINERS 3>&1 1>&2 2>&3)

    if [ -z "$CONTAINER_ID" ]; then
        msg_error "No seleccionaste ningún contenedor. Saliendo."
        exit 1
    fi
    msg_ok "Contenedor seleccionado: $CONTAINER_ID"
}

configure_lxc_for_igpu() {
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"
    CONFIG_PRESENT=true

    if ! grep -q "lxc.cgroup2.devices.allow: c 226:0 rwm" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.cgroup2.devices.allow: c 226:128 rwm" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.cgroup2.devices.allow: c 29:0 rwm" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi

    # Si toda la configuración está presente, no se realiza ninguna acción
    if [ "$CONFIG_PRESENT" = true ]; then
        msg_ok "La configuración de iGPU ya está presente en el contenedor."
        return
    fi

    # Añadir configuración si no está completa
    msg_info "Añadiendo configuración de iGPU al contenedor..."
    echo "features: nesting=1" >> "$CONFIG_FILE"
    echo "lxc.cgroup2.devices.allow: c 226:0 rwm # iGPU" >> "$CONFIG_FILE"
    echo "lxc.cgroup2.devices.allow: c 226:128 rwm # iGPU" >> "$CONFIG_FILE"
    echo "lxc.cgroup2.devices.allow: c 29:0 rwm # Framebuffer" >> "$CONFIG_FILE"
    echo "lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir" >> "$CONFIG_FILE"
    echo "lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file" >> "$CONFIG_FILE"
    echo "lxc.mount.entry: /dev/fb0 dev/fb0 none bind,optional,create=file" >> "$CONFIG_FILE"
    msg_ok "Configuración de iGPU añadida al contenedor."
}


install_igpu_in_container() {
    pct start "$CONTAINER_ID"
    pct exec "$CONTAINER_ID" -- bash -c "
    apt-get update && \
    apt-get install -y va-driver-all intel-opencl-icd vainfo && \
    adduser root video
    "
    msg_ok "Controladores de iGPU instalados dentro del contenedor."
}

# Ejecución
validate_pve_version
select_container
configure_lxc_for_igpu
install_igpu_in_container
msg_ok "Aceleración gráfica iGPU configurada correctamente."
