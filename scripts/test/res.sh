#!/usr/bin/env bash

# ==============================================
# ProxMenux - Menú de Restauración de Backups
# ==============================================

BACKUP_DIR="/root/backups"
PBS_REPO="root@pbs@192.168.100.10:host-backups"
HOSTNAME=$(hostname)

main_menu() {
  OPTION=$(whiptail --title "Restaurar Backup del Host" --menu "¿Desde dónde quieres restaurar?" 15 60 5 \\
    "1" "Restaurar desde archivo local (.tar.gz)" \\
    "2" "Restaurar desde PBS (.pxar)" \\
    "3" "Salir" 3>&1 1>&2 2>&3)

  case "$OPTION" in
    "1") restore_from_local ;;
    "2") restore_from_pbs ;;
    "3") clear; exit 0 ;;
  esac
}

restore_from_local() {
  mapfile -t TAR_FILES < <(find "$BACKUP_DIR" -name "*.tar.gz" 2>/dev/null)

  if [ ${#TAR_FILES[@]} -eq 0 ]; then
    whiptail --msgbox "No se encontraron archivos .tar.gz en $BACKUP_DIR" 10 60
    return
  fi

  MENU_ITEMS=()
  for f in "${TAR_FILES[@]}"; do
    MENU_ITEMS+=("$f" "")
  done

  SELECTED_TAR=$(whiptail --title "Selecciona backup local" --menu "Elige el archivo a restaurar:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  mapfile -t FILE_CONTENT < <(tar -tzf "$SELECTED_TAR")
  MENU_CONTENT=()
  for item in "${FILE_CONTENT[@]}"; do
    MENU_CONTENT+=("$item" "OFF")
  done

  SELECTED_DIRS=$(whiptail --title "Contenido del backup" --checklist "Selecciona qué restaurar (Espacio = seleccionar):" 20 80 15 \\
    "ALL" "Restaurar todo el contenido" OFF \\
    "${MENU_CONTENT[@]}" 3>&1 1>&2 2>&3) || return

  if echo "$SELECTED_DIRS" | grep -q "ALL"; then
    tar -xzf "$SELECTED_TAR" -C /
    whiptail --msgbox "Restauración completa realizada con éxito." 10 60
  else
    for item in $SELECTED_DIRS; do
      item_cleaned=$(echo "$item" | tr -d '"')
      tar -xzf "$SELECTED_TAR" -C / "$item_cleaned"
    done
    whiptail --msgbox "Restauración parcial realizada con éxito." 10 60
  fi
}

restore_from_pbs() {
  mapfile -t BACKUPS < <(proxmox-backup-client list --repository "$PBS_REPO" | grep "$HOSTNAME" | awk '{print $3}')

  if [ ${#BACKUPS[@]} -eq 0 ]; then
    whiptail --msgbox "No se encontraron backups de $HOSTNAME en PBS." 10 60
    return
  fi

  MENU_ITEMS=()
  for backup in "${BACKUPS[@]}"; do
    MENU_ITEMS+=("$backup" "")
  done

  SELECTED_BACKUP=$(whiptail --title "Seleccionar backup en PBS" --menu "Elige un snapshot para restaurar:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  mapfile -t FILES < <(proxmox-backup-client catalog --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP" | awk '{print $1}' | grep ".pxar")

  if [ ${#FILES[@]} -eq 0 ]; then
    whiptail --msgbox "No se encontraron archivos .pxar en ese snapshot." 10 60
    return
  fi

  FILE_OPTIONS=("ALL" "Restaurar todos los archivos" OFF)
  for file in "${FILES[@]}"; do
    FILE_OPTIONS+=("$file" "OFF")
  done

  SELECTED_FILES=$(whiptail --title "Contenido del snapshot PBS" --checklist "Selecciona qué restaurar:" 20 80 15 "${FILE_OPTIONS[@]}" 3>&1 1>&2 2>&3) || return

  RESTORE_DIR="/tmp/pbs-restore-${SELECTED_BACKUP}"
  mkdir -p "$RESTORE_DIR"

  if echo "$SELECTED_FILES" | grep -q "ALL"; then
    for file in "${FILES[@]}"; do
      proxmox-backup-client restore "$file" "$RESTORE_DIR/$(basename "$file" .pxar)" --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP"
    done
    whiptail --msgbox "Restauración completa a $RESTORE_DIR." 10 60
  else
    for file in $SELECTED_FILES; do
      file_cleaned=$(echo "$file" | tr -d '"')
      proxmox-backup-client restore "$file_cleaned" "$RESTORE_DIR/$(basename "$file_cleaned" .pxar)" --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP"
    done
    whiptail --msgbox "Restauración parcial a $RESTORE_DIR." 10 60
  fi
}

# Lanzar menú principal
while true; do main_menu; done
""")

unified_script_path = Path("/mnt/data/restore-unified-menu.sh")
unified_script_path.write_text(unified_restore_script)
unified_script_path.chmod(0o755)
unified_script_path