#!/usr/bin/env bash

# =======================================
# vmenu - Backup Menu for Virtuliser VE
# =======================================

# CONFIGURACIÓN
PBS_REPO="root@pbs@192.168.100.10:host-backups"  # Cambiar IP/datastore si es necesario
HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT="${HOSTNAME}-${TIMESTAMP}"

# LISTA DE DIRECTORIOS RECOMENDADOS
declare -A BACKUP_PATHS=(
    [etc-pve]="/etc/pve"
    [etc-network]="/etc/network"
    [var-lib-pve-cluster]="/var/lib/pve-cluster"
    [root-dir]="/root"
    [etc-ssh]="/etc/ssh"
    [home]="/home"
    [local-bin]="/usr/local/bin"
    [cron]="/etc/cron.d"
    [custom-systemd]="/etc/systemd/system"
)

main_menu() {
    OPTION=$(whiptail --title "Virtuliser Host Backup" --menu "Elige una opción de respaldo:" 20 78 10 \
        "1" "Backup rápido personalizado (tar.gz, local)" \
        "2" "Backup completo del sistema (PBS, backup-client)" \
        "3" "Backup modular al PBS (checklist)" \
        "4" "Backup mínimo automático (tar.gz, local)" \
        "5" "Salir" 3>&1 1>&2 2>&3)

    case "$OPTION" in
        "1") backup_local_tar_checklist ;;
        "2") backup_full_pbs_root ;;
        "3") backup_modular_pbs_checklist ;;
        "4") backup_min_local_tar ;;
        "5") clear; exit 0 ;;
    esac
}

backup_local_tar_checklist() {
    BACKUP_DIR=$(whiptail --inputbox "¿Dónde guardar el backup local? (por defecto /root/backups)" 10 60 3>&1 1>&2 2>&3)
    BACKUP_DIR="${BACKUP_DIR:-/root/backups}"
    mkdir -p "$BACKUP_DIR"

    MENU_OPTIONS=("ALL" "Respaldar todos los directorios sugeridos" OFF)
    for name in "${!BACKUP_PATHS[@]}"; do
        MENU_OPTIONS+=("$name" "${BACKUP_PATHS[$name]}" OFF)
    done

    CHOICES=$(whiptail --checklist "Selecciona los directorios a respaldar:" 20 78 12 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3) || return

    SELECTED=()
    if echo "$CHOICES" | grep -q "ALL"; then
        for path in "${BACKUP_PATHS[@]}"; do SELECTED+=("$path"); done
    else
        for choice in $CHOICES; do
            key=$(echo "$choice" | tr -d '"')
            SELECTED+=("${BACKUP_PATHS[$key]}")
        done
    fi

    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-local-backup-${TIMESTAMP}.tar.gz"
    tar -czf "$BACKUP_FILE" --absolute-names "${SELECTED[@]}" && \
    echo -e "\\nBackup guardado en: $BACKUP_FILE" || \
    echo -e "\\nError al crear el backup local."
    read -p "Pulsa ENTER para continuar..."
}

backup_full_pbs_root() {
    proxmox-backup-client backup \\
        --include-dev /boot/efi \\
        --include-dev /etc/pve \\
        root-${HOSTNAME}.pxar:/ \\
        --repository "$PBS_REPO" && \
    echo -e "\\nBackup completo al PBS finalizado correctamente." || \
    echo -e "\\nError durante el backup completo."
    read -p "Pulsa ENTER para continuar..."
}

backup_modular_pbs_checklist() {
    MENU_OPTIONS=("ALL" "Respaldar todos los directorios sugeridos" OFF)
    for name in "${!BACKUP_PATHS[@]}"; do
        MENU_OPTIONS+=("$name" "${BACKUP_PATHS[$name]}" OFF)
    done

    CHOICES=$(whiptail --checklist "Selecciona qué enviar al PBS:" 20 78 12 "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3) || return

    SELECTED=()
    if echo "$CHOICES" | grep -q "ALL"; then
        for name in "${!BACKUP_PATHS[@]}"; do
            SELECTED+=("${name}.pxar:${BACKUP_PATHS[$name]}")
        done
    else
        for choice in $CHOICES; do
            key=$(echo "$choice" | tr -d '"')
            SELECTED+=("${key}.pxar:${BACKUP_PATHS[$key]}")
        done
    fi

    for entry in "${SELECTED[@]}"; do
        proxmox-backup-client backup "$entry" \\
            --repository "$PBS_REPO" \\
            --backup-type host \\
            --backup-id "$HOSTNAME" \\
            --backup-time "$TIMESTAMP"
    done
    echo -e "\\nBackup modular al PBS finalizado."
    read -p "Pulsa ENTER para continuar..."
}

backup_min_local_tar() {
    BACKUP_DIR="/root/backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-minimal-${TIMESTAMP}.tar.gz"
    tar -czf "$BACKUP_FILE" --absolute-names \
        /etc/pve /etc/network /var/lib/pve-cluster /root && \
    echo -e "\\nBackup mínimo guardado en: $BACKUP_FILE" || \
    echo -e "\\nError durante el backup mínimo."
    read -p "Pulsa ENTER para continuar..."
}

# Lanzar menú principal
while true; do main_menu; done
""")

from pathlib import Path

backup_script_path = Path("/mnt/data/proxmox_host_backup_menu.sh")
backup_script_path.write_text(menu_script)
backup_script_path.chmod(0o755)
backup_script_path