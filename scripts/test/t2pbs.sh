#!/usr/bin/env bash

# =======================================
# ProxMenux - Backup Menu for Proxmox VE
# =======================================

# CONFIGURACIÓN DINÁMICA
# Solicitar datos de conexión a PBS por separado y construir el repositorio final
PBS_REPO_FILE="/etc/proxmenux/pbs-repo.conf"

if [[ -f "$PBS_REPO_FILE" ]]; then
 PBS_REPO=$(tr -d '
[:space:]' < "$PBS_REPO_FILE")
else
  PBS_USER=$(whiptail --inputbox "Introduce el nombre de usuario para el PBS:" 10 60 "root" 3>&1 1>&2 2>&3) || exit
  PBS_HOST=$(whiptail --inputbox "Introduce la IP o nombre del host del PBS:" 10 60 "192.168.0.42" 3>&1 1>&2 2>&3) || exit
  PBS_DATASTORE=$(whiptail --inputbox "Introduce el nombre del datastore PBS:" 10 60 "t6pbs" 3>&1 1>&2 2>&3) || exit

  PBS_REPO="${PBS_USER}@pam@${PBS_HOST}:${PBS_DATASTORE}"
  mkdir -p "$(dirname "$PBS_REPO_FILE")"
  echo "$PBS_REPO" > "$PBS_REPO_FILE"
fi

HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT="${HOSTNAME}-${TIMESTAMP}"
BACKUP_DIR="/var/backups/proxmox-host/tar"

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
    OPTION=$(whiptail --title "Proxmox Host Backup" --menu "Elige una opción de respaldo:" 20 78 10 \
        "1" "Backup rápido personalizado (tar.gz, local)" \
        "2" "Backup rápido personalizado (PBS)" \
        "3" "Backup completo del sistema (tar.gz, local)" \
        "4" "Backup completo del sistema (PBS)" \
        "5" "Backup mínimo automático (tar.gz, local)" \
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
    tar --exclude="$BACKUP_FILE" -czf "$BACKUP_FILE" --absolute-names "${SELECTED[@]}" && \
    echo -e "\nBackup guardado en: $BACKUP_FILE" || \
    echo -e "\nError al crear el backup local."
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
        safe_name=$(echo "$name" | tr '.-' '_')
        SELECTED+=("${safe_name}.pxar:${BACKUP_PATHS[$name]}")
        done
    else
        for choice in $CHOICES; do
        key=$(echo "$choice" | tr -d '"')
        safe_key=$(echo "$key" | tr '.-' '_')
        SELECTED+=("${safe_key}.pxar:${BACKUP_PATHS[$key]}")
        done
    fi

    for entry in "${SELECTED[@]}"; do
      if [[ "$entry" =~ ^[a-zA-Z0-9_-]+\.pxar:/.* ]]; then
        echo ">> Enviando: $entry"
        echo ">> REPO: '$PBS_REPO'"
        proxmox-backup-client backup "$entry" \
          --repository "$PBS_REPO" \
          --backup-type host \
          --backup-id "${HOSTNAME}-$(echo "$entry" | cut -d'.' -f1)" \
          --backup-time "$(date +%s)" \
          --incremental true
      else
        echo ">> Saltado (mal formado): $entry"
      fi
    done

    echo -e "\nBackup modular al PBS finalizado."
    read -p "Pulsa ENTER para continuar..."
}

backup_full_local_root() {
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-full-backup-${TIMESTAMP}.tar.gz"
    echo "Creando backup completo local (excluyendo /proc, /sys, /dev, /run, /mnt, /tmp)..."
    tar --exclude="$BACKUP_DIR" --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run --exclude=/mnt --exclude=/tmp \
        -czf "$BACKUP_FILE" / && \
    echo -e "\nBackup completo guardado en: $BACKUP_FILE" || \
    echo -e "\nError durante el backup completo."
    read -p "Pulsa ENTER para continuar..."
}

backup_full_pbs_root() {
    proxmox-backup-client backup \
        --include-dev /boot/efi \
        --include-dev /etc/pve \
        root-${HOSTNAME}.pxar:/ \
        --repository "$PBS_REPO" \
        --backup-type host \
        --backup-id "$HOSTNAME" \
        --backup-time "$(date +%s)" && \
    echo -e "
Backup completo al PBS finalizado correctamente." || \
    echo -e "
Error durante el backup completo."
    read -p "Pulsa ENTER para continuar..."
    echo -e "\nBackup completo al PBS finalizado correctamente." || \
    echo -e "\nError durante el backup completo."
    read -p "Pulsa ENTER para continuar..."
}

backup_min_local_tar() {
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${BACKUP_DIR}/${HOSTNAME}-minimal-${TIMESTAMP}.tar.gz"
    tar --exclude="$BACKUP_FILE" -czf "$BACKUP_FILE" --absolute-names /etc/pve /etc/network /var/lib/pve-cluster /root && \
    echo -e "\nBackup mínimo guardado en: $BACKUP_FILE" || \
    echo -e "\nError durante el backup mínimo."
    read -p "Pulsa ENTER para continuar..."
}

main_menu
