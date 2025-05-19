#!/usr/bin/env bash

# =======================================
# ProxMenux - Backup Menu for Proxmox VE
# =======================================

PBS_REPO="root@pbs@192.168.100.10:host-backups"
HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT="${HOSTNAME}-${TIMESTAMP}"
BACKUP_DIR="/root/backups"

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
    OPTION=$(whiptail --title "Proxmox Host Backup" --menu "Elige una opción de respaldo:" 20 78 10 \\
        "1" "Backup rápido personalizado (tar.gz, local)" \\
        "2" "Backup rápido personalizado (PBS)" \\
        "3" "Backup completo del sistema (tar.gz, local)" \\
        "4" "Backup completo del sistema (PBS)" \\
        "5" "Backup mínimo automático (tar.gz, local)" \\
        "6" "Salir" 3>&1 1>&2 2>&3)

    case "$OPTION" in
        "1") backup_local_tar_checklist ;;
        "2") backup_modular_pbs_checklist ;;
        "3") backup_full_local_root ;;
        "4") backup_full_pbs_root ;;
        "5") backup_min_local_tar ;;
        "6") clear; exit 0 ;;
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

backup_full_local_root() {
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-full-backup-${TIMESTAMP}.tar.gz"
    echo "Creando backup completo local (excluyendo /proc, /sys, /dev, /run, /mnt, /tmp)..."
    tar --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/mnt --exclude=/tmp \\
        -czf "$BACKUP_FILE" / && \
    echo -e "\\nBackup completo guardado en: $BACKUP_FILE" || \
    echo -e "\\nError durante el backup completo."
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

backup_min_local_tar() {
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-minimal-${TIMESTAMP}.tar.gz"
    tar -czf "$BACKUP_FILE" --absolute-names /etc/pve /etc/network /var/lib/pve-cluster /root && \
    echo -e "\\nBackup mínimo guardado en: $BACKUP_FILE" || \
    echo -e "\\nError durante el backup mínimo."
    read -p "Pulsa ENTER para continuar..."
}

while true; do main_menu; done
""")

backup_script_path = Path("/mnt/data/proxmox_host_backup_menu_v2.sh")
backup_script_path.write_text(backup_script_updated)
backup_script_path.chmod(0o755)
backup_script_path