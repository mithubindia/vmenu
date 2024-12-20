#!/bin/bash

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Validar la versión de Proxmox
validate_pve_version() {
    if ! pveversion | grep -Eq "pve-manager/(8\\.[0-9]+)"; then
        msg_error "Se requiere Proxmox VE 8.0 o superior."
        exit 1
    fi
}

# Selección del contenedor LXC
select_container() {
    CONTAINERS=$(pct list | awk 'NR>1 {print $1, $3}' | xargs -n2)
    CONTAINER_ID=$(whiptail --title "Seleccionar Contenedor" --menu "Selecciona un contenedor LXC:" 15 60 5 $CONTAINERS 3>&1 1>&2 2>&3)

    if [ -z "$CONTAINER_ID" ]; then
        msg_error "No seleccionaste ningún contenedor. Saliendo."
        exit 1
    fi
    msg_ok "Contenedor seleccionado: $CONTAINER_ID"
}

# Asegurarse de que el contenedor sea privilegiado
ensure_privileged_container() {
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"

    # Validar que el archivo de configuración exista
    if [ ! -f "$CONFIG_FILE" ]; then
        msg_error "Archivo de configuración del contenedor $CONTAINER_ID no encontrado."
        exit 1
    fi

    # Verificar si el contenedor es no privilegiado
    if grep -q "^unprivileged: 1" "$CONFIG_FILE"; then
        msg_info "El contenedor es no privilegiado. Cambiando a privilegiado..."

        # Cambiar la configuración a privilegiado
        sed -i "s/^unprivileged: 1/unprivileged: 0/" "$CONFIG_FILE"

        # Ajustar permisos del sistema de archivos si el almacenamiento es 'dir'
        STORAGE_TYPE=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk -F, '{print $2}' | cut -d'=' -f2)
        if [[ "$STORAGE_TYPE" == "dir" ]]; then
            STORAGE_PATH=$(pct config "$CONTAINER_ID" | grep "^rootfs:" | awk '{print $2}' | cut -d',' -f1)
            chown -R root:root "$STORAGE_PATH"
            msg_ok "Permisos ajustados para almacenamiento en directorios."
        fi

        msg_ok "Contenedor cambiado a privilegiado."
    else
        msg_ok "El contenedor ya es privilegiado."
    fi
}

# Apagar el contenedor si está corriendo
stop_container_if_running() {
    if pct status "$CONTAINER_ID" | grep -q "status: running"; then
        msg_info "Apagando el contenedor $CONTAINER_ID..."
        pct stop "$CONTAINER_ID"
        msg_ok "Contenedor $CONTAINER_ID apagado."
    fi
}

# Configurar iGPU en el contenedor
configure_lxc_for_igpu() {
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"
    CONFIG_PRESENT=true

    # Verificar cada línea específica para la configuración de iGPU
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

# Iniciar el contenedor
start_container() {
    msg_info "Iniciando el contenedor $CONTAINER_ID..."
    pct start "$CONTAINER_ID"
    msg_ok "Contenedor $CONTAINER_ID iniciado."
}

# Instalar controladores de iGPU en el contenedor
install_igpu_in_container() {
    msg_info "Instalando controladores de iGPU dentro del contenedor..."
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
ensure_privileged_container
stop_container_if_running
configure_lxc_for_igpu
start_container
install_igpu_in_container
msg_ok "Aceleración gráfica iGPU configurada correctamente."
