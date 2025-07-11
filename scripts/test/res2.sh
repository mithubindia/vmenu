#!/usr/bin/env bash

# ========================================
# vmenu - Menú completo de restauración
# ========================================

BACKUP_DIR="/root/backups"
PBS_REPO="root@pbs@192.168.100.10:host-backups"
HOSTNAME=$(hostname)

main_menu() {
  OPTION=$(whiptail --title "Restaurar Backup del Host" --menu "Selecciona el origen del backup:" 15 60 4 \\
    "1" "Restaurar desde archivo local (.tar.gz)" \\
    "2" "Restaurar desde PBS (.pxar)" \\
    "3" "Salir" 3>&1 1>&2 2>&3)

  case "$OPTION" in
    "1") local_restore_menu ;;
    "2") pbs_restore_menu ;;
    "3") clear; exit 0 ;;
  esac
}

local_restore_menu() {
  OPTION=$(whiptail --title "Restaurar desde archivo local" --menu "Selecciona el tipo de restauración:" 15 60 2 \\
    "1" "Restauración completa del sistema" \\
    "2" "Restauración manual (archivos o directorios)" 3>&1 1>&2 2>&3)

  case "$OPTION" in
    "1") restore_local_full ;;
    "2") restore_local_manual ;;
  esac
}

pbs_restore_menu() {
  OPTION=$(whiptail --title "Restaurar desde PBS" --menu "Selecciona el tipo de restauración:" 15 60 2 \\
    "1" "Restauración completa del sistema" \\
    "2" "Restauración manual (archivos o directorios)" 3>&1 1>&2 2>&3)

  case "$OPTION" in
    "1") restore_pbs_full ;;
    "2") restore_pbs_manual ;;
  esac
}

restore_local_full() {
  mapfile -t TAR_FILES < <(find "$BACKUP_DIR" -name "*.tar.gz" 2>/dev/null)
  [[ ${#TAR_FILES[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron backups en $BACKUP_DIR" 10 60 && return

  MENU_ITEMS=()
  for f in "${TAR_FILES[@]}"; do MENU_ITEMS+=("$f" ""); done

  SELECTED=$(whiptail --title "Seleccionar backup" --menu "Elige el archivo para restaurar completamente:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  CONFIRM=$(whiptail --title "Confirmar restauración" --yesno "¿Deseas sobrescribir el sistema con este backup?" 10 60)
  [[ $? -ne 0 ]] && return

  tar -xzf "$SELECTED" -C /
  whiptail --msgbox "Restauración completa realizada con éxito." 10 60
}

restore_local_manual() {
  mapfile -t TAR_FILES < <(find "$BACKUP_DIR" -name "*.tar.gz" 2>/dev/null)
  [[ ${#TAR_FILES[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron backups en $BACKUP_DIR" 10 60 && return

  MENU_ITEMS=()
  for f in "${TAR_FILES[@]}"; do MENU_ITEMS+=("$f" ""); done

  SELECTED=$(whiptail --title "Seleccionar backup" --menu "Elige el archivo a examinar:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return
  mapfile -t CONTENT < <(tar -tzf "$SELECTED")
  MENU_CONTENT=()
  for item in "${CONTENT[@]}"; do MENU_CONTENT+=("$item" "OFF"); done

  SELECTED_ITEMS=$(whiptail --title "Seleccionar contenido" --checklist "Selecciona qué restaurar:" 20 80 15 "${MENU_CONTENT[@]}" 3>&1 1>&2 2>&3) || return

  for item in $SELECTED_ITEMS; do
    CLEAN_ITEM=$(echo "$item" | tr -d '"')
    tar -xzf "$SELECTED" -C / "$CLEAN_ITEM"
  done

  whiptail --msgbox "Restauración parcial realizada con éxito." 10 60
}

restore_pbs_full() {
  mapfile -t BACKUPS < <(proxmox-backup-client list --repository "$PBS_REPO" | grep "$HOSTNAME" | awk '{print $3}')
  [[ ${#BACKUPS[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron backups en PBS." 10 60 && return

  MENU_ITEMS=()
  for backup in "${BACKUPS[@]}"; do MENU_ITEMS+=("$backup" ""); done

  SELECTED_BACKUP=$(whiptail --title "Snapshot PBS" --menu "Selecciona el snapshot para restaurar:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  mapfile -t FILES < <(proxmox-backup-client catalog --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP" | awk '{print $1}' | grep ".pxar")
  [[ ${#FILES[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron archivos .pxar." 10 60 && return

  FILE_OPTIONS=()
  for file in "${FILES[@]}"; do FILE_OPTIONS+=("$file" "OFF"); done
  SELECTED_FILE=$(whiptail --title "Archivo .pxar" --radiolist "Selecciona el archivo para restaurar completamente:" 20 80 10 "${FILE_OPTIONS[@]}" 3>&1 1>&2 2>&3) || return
  FILE_CLEAN=$(echo "$SELECTED_FILE" | tr -d '"')

  CONFIRM=$(whiptail --title "Confirmar restauración" --yesno "¿Deseas sobrescribir el sistema con ${FILE_CLEAN}?" 10 70)
  [[ $? -ne 0 ]] && return

  proxmox-backup-client restore "$FILE_CLEAN" / --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP"
  whiptail --msgbox "Restauración completa realizada con éxito." 10 60
}

restore_pbs_manual() {
  mapfile -t BACKUPS < <(proxmox-backup-client list --repository "$PBS_REPO" | grep "$HOSTNAME" | awk '{print $3}')
  [[ ${#BACKUPS[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron backups en PBS." 10 60 && return

  MENU_ITEMS=()
  for backup in "${BACKUPS[@]}"; do MENU_ITEMS+=("$backup" ""); done

  SELECTED_BACKUP=$(whiptail --title "Snapshot PBS" --menu "Selecciona el snapshot para explorar:" 20 70 10 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  mapfile -t FILES < <(proxmox-backup-client catalog --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP" | awk '{print $1}' | grep ".pxar")
  [[ ${#FILES[@]} -eq 0 ]] && whiptail --msgbox "No se encontraron archivos .pxar." 10 60 && return

  FILE_OPTIONS=()
  for file in "${FILES[@]}"; do FILE_OPTIONS+=("$file" "OFF"); done
  SELECTED_FILE=$(whiptail --title "Archivo .pxar" --radiolist "Selecciona el archivo para restaurar parcialmente:" 20 80 10 "${FILE_OPTIONS[@]}" 3>&1 1>&2 2>&3) || return
  FILE_CLEAN=$(echo "$SELECTED_FILE" | tr -d '"')

  TMP_DIR="/tmp/restore-${RANDOM}"
  mkdir -p "$TMP_DIR"
  proxmox-backup-client restore "$FILE_CLEAN" "$TMP_DIR" --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP"

  mapfile -t CONTENT < <(cd "$TMP_DIR" && find . -type f -o -type d)
  RESTORE_ITEMS=()
  for entry in "${CONTENT[@]}"; do RESTORE_ITEMS+=("$entry" "OFF"); done

  SELECTED_ITEMS=$(whiptail --title "Contenido del backup" --checklist "Selecciona qué restaurar en el sistema:" 20 80 15 "${RESTORE_ITEMS[@]}" 3>&1 1>&2 2>&3) || return

  for item in $SELECTED_ITEMS; do
    CLEAN_ITEM=$(echo "$item" | tr -d '"')
    cp -r "$TMP_DIR/$CLEAN_ITEM" "/$CLEAN_ITEM"
  done

  rm -rf "$TMP_DIR"
  whiptail --msgbox "Restauración parcial completada y archivos temporales eliminados." 10 60
}

while true; do main_menu; done
""")

script_path = Path("/mnt/data/proxmox-restore-menu.sh")
script_path.write_text(full_menu_script)
script_path.chmod(0o755)
script_path