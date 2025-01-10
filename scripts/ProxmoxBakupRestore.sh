#!/bin/bash

# Configuración
SCRIPT_VERSION="1.3"
BACKUP_DIR="/root/proxmox_backups"
LOG_FILE="/var/log/proxmox_backup_restore.log"

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Variable global para el modo de interfaz
INTERFACE_MODE=""

# Funciones de utilidad
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo -e "$1"
}

error() {
    log "${RED}ERROR: $1${NC}"
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        whiptail --title "Error" --msgbox "$1" 8 78
    else
        echo -e "${RED}ERROR: $1${NC}"
    fi
    exit 1
}

success() {
    log "${GREEN}$1${NC}"
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        whiptail --title "Éxito" --msgbox "$1" 8 78
    else
        echo -e "${GREEN}$1${NC}"
    fi
}

warning() {
    log "${YELLOW}ADVERTENCIA: $1${NC}"
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        whiptail --title "Advertencia" --msgbox "$1" 8 78
    else
        echo -e "${YELLOW}ADVERTENCIA: $1${NC}"
    fi
}

# Función para seleccionar el modo de interfaz
select_interface_mode() {
    if [ "$(tty)" = "/dev/tty1" ] || [ "$(tty)" = "/dev/console" ]; then
        echo "Ejecutando en consola física. Usando interfaz de texto."
        INTERFACE_MODE="echo"
    elif command -v whiptail >/dev/null 2>&1; then
        echo "Ejecutando en terminal remota. Usando interfaz whiptail."
        INTERFACE_MODE="whiptail"
    else
        echo "whiptail no está disponible. Usando interfaz de texto."
        INTERFACE_MODE="echo"
    fi
}

# Función para mostrar el menú principal
show_main_menu() {
    while true; do
        if [ "$INTERFACE_MODE" = "whiptail" ]; then
            CHOICE=$(whiptail --title "Proxmox Backup & Restore Tool" --menu "Seleccione una opción:" 15 60 3 \
            "1" "Realizar copia de seguridad" \
            "2" "Restaurar copia de seguridad" \
            "3" "Salir" 3>&1 1>&2 2>&3)
        else
            echo "Proxmox Backup & Restore Tool"
            echo "1. Realizar copia de seguridad"
            echo "2. Restaurar copia de seguridad"
            echo "3. Salir"
            read -p "Seleccione una opción: " CHOICE
        fi

        case $CHOICE in
            1) perform_backup ;;
            2) perform_restore ;;
            3) exit 0 ;;
            *) echo "Opción no válida. Por favor, intente de nuevo." ;;
        esac
    done
}

# Función para seleccionar la ubicación de la copia de seguridad
select_backup_location() {
    local options=()
    local i=1

    # Ubicaciones recomendadas
    options+=("/root/backups/" "/var/lib/vz/dump/")

    # Detectar discos USB
    local usb_disks=$(lsblk -ndo NAME,TRAN,SIZE | awk '$2=="usb" {print "/dev/"$1}')
    options+=($usb_disks)

    # Otros discos disponibles
    local other_disks=$(lsblk -ndo NAME,SIZE,FSTYPE | grep -vE "^(sd[a-z]|nvme[0-9]n[0-9])" | awk '$3!="" {print "/dev/"$1}')
    options+=($other_disks)

    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        BACKUP_LOCATION=$(whiptail --title "Seleccionar ubicación de copia de seguridad" \
            --menu "Elija dónde guardar la copia de seguridad:" 20 78 10 \
            $(for i in "${!options[@]}"; do echo "$i ${options[$i]}"; done) \
            "C" "Introducir ruta personalizada" 3>&1 1>&2 2>&3)
    else
        echo "Seleccionar ubicación de copia de seguridad:"
        for i in "${!options[@]}"; do
            echo "$i. ${options[$i]}"
        done
        echo "C. Introducir ruta personalizada"
        read -p "Elija dónde guardar la copia de seguridad: " BACKUP_LOCATION
    fi

    if [[ $BACKUP_LOCATION == "C" ]]; then
        if [ "$INTERFACE_MODE" = "whiptail" ]; then
            BACKUP_LOCATION=$(whiptail --inputbox "Introduzca la ruta personalizada:" 8 78 "/mnt/backup" --title "Ruta personalizada" 3>&1 1>&2 2>&3)
        else
            read -p "Introduzca la ruta personalizada: " BACKUP_LOCATION
        fi
    elif [[ $BACKUP_LOCATION =~ ^[0-9]+$ ]]; then
        BACKUP_LOCATION=${options[$BACKUP_LOCATION]}
    fi

    echo "$BACKUP_LOCATION"
}

# Función para realizar la copia de seguridad
perform_backup() {
    local BACKUP_LOCATION=$(select_backup_location)
    
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        local BACKUP_TYPE=$(whiptail --title "Tipo de copia de seguridad" --menu "Seleccione el tipo de copia de seguridad:" 15 60 2 \
            "1" "Copia de seguridad total" \
            "2" "Copia de seguridad personalizada" 3>&1 1>&2 2>&3)
    else
        echo "Tipo de copia de seguridad:"
        echo "1. Copia de seguridad total"
        echo "2. Copia de seguridad personalizada"
        read -p "Seleccione el tipo de copia de seguridad: " BACKUP_TYPE
    fi

    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BACKUP_PATH="${BACKUP_LOCATION}/proxmox_backup_${TIMESTAMP}"
    mkdir -p "$BACKUP_PATH" || error "No se pudo crear el directorio de copia de seguridad."

    case $BACKUP_TYPE in
        1) backup_total "$BACKUP_PATH" ;;
        2) backup_personalizada "$BACKUP_PATH" ;;
        *) error "Opción no válida." ;;
    esac

    # Guardar versión de Proxmox
    pveversion > "$BACKUP_PATH/pve_version.txt"

    # Guardar mapa de rutas de almacenamiento
    pvesm status --output-format=json > "$BACKUP_PATH/storage_paths.json"

    success "Copia de seguridad completada en $BACKUP_PATH"
}

# Función para realizar copia de seguridad total
backup_total() {
    local BACKUP_PATH=$1
    log "Iniciando copia de seguridad total..."

    # Copiar configuraciones de Proxmox
    cp -r /etc/pve "$BACKUP_PATH/etc_pve" || warning "Error al copiar /etc/pve"
    cp -r /etc/network "$BACKUP_PATH/etc_network" || warning "Error al copiar /etc/network"
    cp /etc/hostname "$BACKUP_PATH/etc_hostname" || warning "Error al copiar /etc/hostname"
    cp /etc/hosts "$BACKUP_PATH/etc_hosts" || warning "Error al copiar /etc/hosts"

    # Copiar logs relevantes
    mkdir -p "$BACKUP_PATH/var_log"
    cp /var/log/pveam.log "$BACKUP_PATH/var_log/" || warning "Error al copiar pveam.log"
    cp /var/log/pvedaemon.log "$BACKUP_PATH/var_log/" || warning "Error al copiar pvedaemon.log"

    # Copiar configuraciones de almacenamiento
    cp /etc/pve/storage.cfg "$BACKUP_PATH/storage.cfg" || warning "Error al copiar storage.cfg"

    # Copiar configuraciones de usuarios y permisos
    cp /etc/pve/user.cfg "$BACKUP_PATH/user.cfg" || warning "Error al copiar user.cfg"
    cp /etc/pve/groups.cfg "$BACKUP_PATH/groups.cfg" || warning "Error al copiar groups.cfg"

    # Copiar configuraciones de firewall
    cp -r /etc/pve/firewall "$BACKUP_PATH/firewall" || warning "Error al copiar configuraciones de firewall"

    # Copiar metadatos de VMs y contenedores (sin incluir discos o snapshots)
    mkdir -p "$BACKUP_PATH/vms_metadata"
    for vmid in $(qm list | awk '{if(NR>1) print $1}'); do
        qm config $vmid > "$BACKUP_PATH/vms_metadata/vm_${vmid}.conf"
    done

    mkdir -p "$BACKUP_PATH/cts_metadata"
    for ctid in $(pct list | awk '{if(NR>1) print $1}'); do
        pct config $ctid > "$BACKUP_PATH/cts_metadata/ct_${ctid}.conf"
    done

    log "Copia de seguridad total completada."
}

# Función para realizar copia de seguridad personalizada
backup_personalizada() {
    local BACKUP_PATH=$1
    log "Iniciando copia de seguridad personalizada..."

    local options=(
        "1" "Configuración del sistema Proxmox" ON
        "2" "Configuraciones de almacenamiento" ON
        "3" "Configuraciones de red" ON
        "4" "Usuarios y permisos" ON
        "5" "Logs del sistema relevantes" OFF
        "6" "Configuraciones de firewall" ON
        "7" "Metadatos de VMs y contenedores" ON
    )

    local SELECTED_OPTIONS
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        SELECTED_OPTIONS=$(whiptail --title "Selección de componentes" \
            --checklist "Seleccione los componentes a respaldar:" 20 78 7 \
            "${options[@]}" 3>&1 1>&2 2>&3)
    else
        echo "Selección de componentes a respaldar:"
        for ((i=0; i<${#options[@]}; i+=3)); do
            echo "${options[i]}. ${options[i+1]}"
        done
        read -p "Ingrese los números de los componentes a respaldar (separados por espacio): " -a selections
        for sel in "${selections[@]}"; do
            SELECTED_OPTIONS+="$sel "
        done
    fi

    for option in $SELECTED_OPTIONS; do
        case $option in
            1)
                cp -r /etc/pve "$BACKUP_PATH/etc_pve" || warning "Error al copiar /etc/pve"
                cp /etc/hostname "$BACKUP_PATH/etc_hostname" || warning "Error al copiar /etc/hostname"
                cp /etc/hosts "$BACKUP_PATH/etc_hosts" || warning "Error al copiar /etc/hosts"
                ;;
            2)
                cp /etc/pve/storage.cfg "$BACKUP_PATH/storage.cfg" || warning "Error al copiar storage.cfg"
                ;;
            3)
                cp -r /etc/network "$BACKUP_PATH/etc_network" || warning "Error al copiar /etc/network"
                ;;
            4)
                cp /etc/pve/user.cfg "$BACKUP_PATH/user.cfg" || warning "Error al copiar user.cfg"
                cp /etc/pve/groups.cfg "$BACKUP_PATH/groups.cfg" || warning "Error al copiar groups.cfg"
                ;;
            5)
                mkdir -p "$BACKUP_PATH/var_log"
                cp /var/log/pveam.log "$BACKUP_PATH/var_log/" || warning "Error al copiar pveam.log"
                cp /var/log/pvedaemon.log "$BACKUP_PATH/var_log/" || warning "Error al copiar pvedaemon.log"
                ;;
            6)
                cp -r /etc/pve/firewall "$BACKUP_PATH/firewall" || warning "Error al copiar configuraciones de firewall"
                ;;
            7)
                mkdir -p "$BACKUP_PATH/vms_metadata"
                for vmid in $(qm list | awk '{if(NR>1) print $1}'); do
                    qm config $vmid > "$BACKUP_PATH/vms_metadata/vm_${vmid}.conf"
                done

                mkdir -p "$BACKUP_PATH/cts_metadata"
                for ctid in $(pct list | awk '{if(NR>1) print $1}'); do
                    pct config $ctid > "$BACKUP_PATH/cts_metadata/ct_${ctid}.conf"
                done
                ;;
        esac
    done

    log "Copia de seguridad personalizada completada."
}

# Función para restaurar desde una copia de seguridad
perform_restore() {
    local BACKUP_LOCATION
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        BACKUP_LOCATION=$(whiptail --inputbox "Introduzca la ruta de la copia de seguridad:" 8 78 "/root/proxmox_backups" --title "Restauración" 3>&1 1>&2 2>&3)
    else
        read -p "Introduzca la ruta de la copia de seguridad: " BACKUP_LOCATION
    fi

    local backups=($(ls -d ${BACKUP_LOCATION}/proxmox_backup_* 2>/dev/null))
    if [ ${#backups[@]} -eq 0 ]; then
        error "No se encontraron copias de seguridad en $BACKUP_LOCATION"
    fi

    local SELECTED_BACKUP
    if [ "$INTERFACE_MODE" = "whiptail" ]; then
        local options=()
        for i in "${!backups[@]}"; do
            options+=("$i" "$(basename ${backups[$i]})")
        done
        SELECTED_BACKUP=$(whiptail --title "Seleccionar copia de seguridad" \
            --menu "Elija la copia de seguridad a restaurar:" 20 78 10 \
            "${options[@]}" 3>&1 1>&2 2>&3)
    else
        echo "Copias de seguridad disponibles:"
        for i in "${!backups[@]}"; do
            echo "$i. $(basename ${backups[$i]})"
        done
        read -p "Elija la copia de seguridad a restaurar: " SELECTED_BACKUP
    fi

    local BACKUP_PATH="${backups[$SELECTED_BACKUP]}"

    # Verificar compatibilidad de versiones
    if ! verify_pve_version "$BACKUP_PATH"; then
        if [ "$INTERFACE_MODE" = "whiptail" ]; then
            if ! whiptail --yesno "La versión de Proxmox es diferente. ¿Desea continuar con la restauración?" 8 78; then
                error "Restauración cancelada debido a diferencia de versiones."
            fi
        else
            read -p "La versión de Proxmox es diferente. ¿Desea continuar con la restauración? (s/n): " response
            if [[ ! $response =~ ^[Ss]$ ]]; then
                error "Restauración cancelada debido a diferencia de versiones."
            fi
        fi
    fi

    # Verificar cambios de hardware
    if ! verify_hardware "$BACKUP_PATH"; then
        warning "Se detectaron cambios en el hardware. Revise el informe en $BACKUP_PATH/hardware_changes.txt"
    fi

    # Verificar y ajustar paths de almacenamiento
    if ! adjust_storage_paths "$BACKUP_PATH"; then
        warning "Algunas rutas de almacenamiento han cambiado. Revise y ajuste manualmente si es necesario."
    fi

    # Realizar la restauración
    restore_files "$BACKUP_PATH"

    success "Restauración completada. Se recomienda reiniciar el sistema."
}

# Función para verificar la versión de Proxmox
verify_pve_version() {
    local BACKUP_PATH=$1
    local backup_version=$(cat "$BACKUP_PATH/pve_version.txt")
    local current_version=$(pveversion | grep "pve-manager/")

    if [ "$backup_version" != "$current_version" ]; then
        warning "La versión de Proxmox actual ($current_version) es diferente de la versión del backup ($backup_version)."
        return 1
    fi
    return 0
}

# Función para verificar cambios de hardware
verify_hardware() {
    local BACKUP_PATH=$1
    local current_hw=$(lshw -short)
    local backup_hw_file="$BACKUP_PATH/hardware_info.txt"

    if [ ! -f "$backup_hw_file" ]; then
        warning "No se encontró información de hardware en la copia de seguridad."
        return 1
    fi

    local backup_hw=$(cat "$backup_hw_file")
    if [ "$current_hw" != "$backup_hw" ]; then
        diff <(echo "$backup_hw") <(echo "$current_hw") > "$BACKUP_PATH/hardware_changes.txt"
        return 1
    fi
    return 0
}

# Función para ajustar rutas de almacenamiento
adjust_storage_paths() {
    local BACKUP_PATH=$1
    local old_paths_file="$BACKUP_PATH/storage_paths.json"
    local new_paths=$(pvesm status --output-format=json)

    if [ ! -f "$old_paths_file" ]; then
        warning "No se encontró información de rutas de almacenamiento en la copia de seguridad."
        return 1
    fi

    local old_paths=$(cat "$old_paths_file")
    if [ "$new_paths" != "$old_paths" ]; then
        echo "Se detectaron cambios en las rutas de almacenamiento:"
        diff <(echo "$old_paths") <(echo "$new_paths")
        
        if [ "$INTERFACE_MODE" = "whiptail" ]; then
            if whiptail --yesno "¿Desea ajustar automáticamente las rutas de almacenamiento?" 8 78; then
                # Aquí iría la lógica para ajustar automáticamente las rutas
                # Por ejemplo, actualizando los archivos de configuración relevantes
                warning "Ajuste automático de rutas no implementado. Por favor, revise manualmente."
            else
                warning "Las rutas de almacenamiento deben ajustarse manualmente."
            fi
        else
            read -p "¿Desea ajustar automáticamente las rutas de almacenamiento? (s/n): " response
            if [[ $response =~ ^[Ss]$ ]]; then
                # Aquí iría la lógica para ajustar automáticamente las rutas
                warning "Ajuste automático de rutas no implementado. Por favor, revise manualmente."
            else
                warning "Las rutas de almacenamiento deben ajustarse manualmente."
            fi
        fi
        return 1
    fi
    return 0
}

# Función para restaurar archivos
restore_files() {
    local BACKUP_PATH=$1
    log "Iniciando restauración de archivos..."

    # Restaurar configuraciones de Proxmox
    if [ -d "$BACKUP_PATH/etc_pve" ]; then
        cp -r "$BACKUP_PATH/etc_pve"/* /etc/pve/ || warning "Error al restaurar /etc/pve"
    fi

    if [ -d "$BACKUP_PATH/etc_network" ]; then
        cp -r "$BACKUP_PATH/etc_network"/* /etc/network/ || warning "Error al restaurar /etc/network"
    fi

    if [ -f "$BACKUP_PATH/etc_hostname" ]; then
        cp "$BACKUP_PATH/etc_hostname" /etc/hostname || warning "Error al restaurar /etc/hostname"
    fi

    if [ -f "$BACKUP_PATH/etc_hosts" ]; then
        cp "$BACKUP_PATH/etc_hosts" /etc/hosts || warning "Error al restaurar /etc/hosts"
    fi

    # Restaurar logs
    if [ -d "$BACKUP_PATH/var_log" ]; then
        cp "$BACKUP_PATH/var_log"/* /var/log/ || warning "Error al restaurar logs"
    fi

    # Restaurar configuraciones de almacenamiento
    if [ -f "$BACKUP_PATH/storage.cfg" ]; then
        cp "$BACKUP_PATH/storage.cfg" /etc/pve/storage.cfg || warning "Error al restaurar storage.cfg"
    fi

    # Restaurar configuraciones de usuarios y permisos
    if [ -f "$BACKUP_PATH/user.cfg" ]; then
        cp "$BACKUP_PATH/user.cfg" /etc/pve/user.cfg || warning "Error al restaurar user.cfg"
    fi

    if [ -f "$BACKUP_PATH/groups.cfg" ]; then
        cp "$BACKUP_PATH/groups.cfg" /etc/pve/groups.cfg || warning "Error al restaurar groups.cfg"
    fi

    # Restaurar configuraciones de firewall
    if [ -d "$BACKUP_PATH/firewall" ]; then
        cp -r "$BACKUP_PATH/firewall"/* /etc/pve/firewall/ || warning "Error al restaurar configuraciones de firewall"
    fi

    # Restaurar metadatos de VMs y contenedores
    if [ -d "$BACKUP_PATH/vms_metadata" ]; then
        for conf in "$BACKUP_PATH/vms_metadata"/*.conf; do
            vmid=$(basename "$conf" .conf | cut -d'_' -f2)
            qm importconfig $vmid "$conf" || warning "Error al restaurar configuración de VM $vmid"
        done
    fi

    if [ -d "$BACKUP_PATH/cts_metadata" ]; then
        for conf in "$BACKUP_PATH/cts_metadata"/*.conf; do
            ctid=$(basename "$conf" .conf | cut -d'_' -f2)
            pct importconfig $ctid "$conf" || warning "Error al restaurar configuración de CT $ctid"
        done
    fi

    log "Restauración de archivos completada."
}

# Iniciar el script
select_interface_mode
show_main_menu

