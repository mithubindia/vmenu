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

# Verificar y configurar repositorios en el host
verify_and_add_repos() {
    msg_info "Verificando y configurando repositorios necesarios en el host..."

    if ! grep -q "pve-no-subscription" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "deb http://download.proxmox.com/debian/pve $(lsb_release -sc) pve-no-subscription" | tee /etc/apt/sources.list.d/pve-no-subscription.list
        msg_ok "Repositorio pve-no-subscription añadido."
    else
        msg_ok "Repositorio pve-no-subscription ya configurado."
    fi

    if ! grep -q "non-free-firmware" /etc/apt/sources.list; then
        echo "deb http://deb.debian.org/debian $(lsb_release -sc) main contrib non-free-firmware
deb http://deb.debian.org/debian $(lsb_release -sc)-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security $(lsb_release -sc)-security main contrib non-free-firmware" | tee -a /etc/apt/sources.list
        msg_ok "Repositorios non-free-firmware añadidos."
    else
        msg_ok "Repositorios non-free-firmware ya configurados."
    fi

    apt-get update
    msg_ok "Repositorios verificados y actualizados."
}

# Instalar controladores de Coral TPU en el host
install_coral_host() {
    FORCE_REINSTALL=$1

    # Verificar si el controlador ya está instalado
    if [ "$FORCE_REINSTALL" != "--force" ]; then
        msg_info "Verificando si los controladores de Coral TPU ya están instalados..."
        if dpkg -l | grep -qw gasket-dkms; then
            msg_ok "Los controladores de Coral TPU ya están instalados."
            return 0
        fi
    fi

    msg_info "Instalando controladores de Coral TPU en el host..."
    verify_and_add_repos
    apt-get install -y git devscripts dh-dkms dkms pve-headers-$(uname -r)

    # Clonar la rama predeterminada del repositorio
    cd /tmp
    rm -rf gasket-driver
    msg_info "Clonando la rama predeterminada del repositorio de Google Coral..."
    git clone https://github.com/google/gasket-driver.git
    if [ $? -ne 0 ]; then
        msg_error "No se pudo clonar el repositorio."
        exit 1
    fi

    cd gasket-driver/

    # Construir e instalar el paquete .deb
    debuild -us -uc -tc -b
    if [ $? -ne 0 ]; then
        msg_error "Error al construir los paquetes del controlador."
        exit 1
    fi

    dpkg -i ../gasket-dkms_*.deb
    if [ $? -ne 0 ]; then
        msg_error "Error al instalar los paquetes del controlador."
        exit 1
    fi

    msg_ok "Controladores de Coral TPU instalados en el host desde la rama predeterminada."
}

# Configurar Coral TPU en el contenedor
configure_lxc_for_coral() {
    CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"
    CONFIG_PRESENT=true

    # Verificar cada línea específica para la configuración de Coral TPU
    if ! grep -q "lxc.cgroup2.devices.allow: c 189:* rwm" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi
    if ! grep -q "lxc.mount.entry: /dev/apex_0 dev/apex_0 none bind,optional,create=file" "$CONFIG_FILE"; then
        CONFIG_PRESENT=false
    fi

    # Si toda la configuración está presente, no se realiza ninguna acción
    if [ "$CONFIG_PRESENT" = true ]; then
        msg_ok "La configuración de Coral TPU ya está presente en el contenedor."
        return
    fi

    # Añadir configuración si no está completa
    msg_info "Añadiendo configuración de Coral TPU al contenedor..."
    echo "lxc.cgroup2.devices.allow: c 189:* rwm # Coral USB" >> "$CONFIG_FILE"
    echo "lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir" >> "$CONFIG_FILE"
    echo "lxc.mount.entry: /dev/apex_0 dev/apex_0 none bind,optional,create=file" >> "$CONFIG_FILE"
    msg_ok "Configuración de Coral TPU añadida al contenedor."
}

# Iniciar el contenedor
start_container() {
    msg_info "Iniciando el contenedor $CONTAINER_ID..."
    pct start "$CONTAINER_ID"
    msg_ok "Contenedor $CONTAINER_ID iniciado."
}

# Instalar controladores de Coral TPU en el contenedor
install_coral_in_container() {
    msg_info "Detectando dispositivos Coral TPU dentro del contenedor..."
    CORAL_M2=$(lspci | grep -i "Global Unichip")

    if [[ -n "$CORAL_M2" ]]; then
        DRIVER_OPTION=$(whiptail --title "Seleccionar versión de controladores" \
            --menu "Elige la versión de controladores para Coral M.2:\n\nPrecaución: El modo máximo genera más calor." 15 60 2 \
            1 "libedgetpu1-std (rendimiento estándar)" \
            2 "libedgetpu1-max (máximo rendimiento)" 3>&1 1>&2 2>&3)

        case "$DRIVER_OPTION" in
            1) DRIVER_PACKAGE="libedgetpu1-std" ;;
            2) DRIVER_PACKAGE="libedgetpu1-max" ;;
            *) DRIVER_PACKAGE="libedgetpu1-std" ;;
        esac
    else
        DRIVER_PACKAGE="libedgetpu1-std"
    fi

    pct start "$CONTAINER_ID"
    pct exec "$CONTAINER_ID" -- bash -c "
    apt-get update && \
    apt-get install -y gnupg python3 python3-pip python3-venv && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/coral-edgetpu.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/coral-edgetpu.gpg] https://packages.cloud.google.com/apt coral-edgetpu-stable main' | tee /etc/apt/sources.list.d/coral-edgetpu.list && \
    apt-get update && \
    apt-get install -y $DRIVER_PACKAGE
    "
    msg_ok "Controladores de Coral TPU instalados dentro del contenedor."
}

# Flujo principal del script
validate_pve_version
select_container
ensure_privileged_container
stop_container_if_running
install_coral_host
configure_lxc_for_coral
start_container
install_coral_in_container

msg_ok "Configuración de Coral TPU completada con éxito."
