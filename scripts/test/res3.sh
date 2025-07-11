#!/usr/bin/env bash

# ================================
# vmenu - Restauración completa desde PBS con autoreparación
# ================================

PBS_REPO="root@pbs@192.168.100.10:host-backups"
HOSTNAME=$(hostname)

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

  CONFIRM=$(whiptail --title "Confirmar restauración" --yesno "¿Deseas sobrescribir el sistema con ${FILE_CLEAN}?\nEsto restaurará todos los archivos y puede requerir reinstalar GRUB y el kernel." 12 70)
  [[ $? -ne 0 ]] && return

  # Restauración principal
  proxmox-backup-client restore "$FILE_CLEAN" / --repository "$PBS_REPO" --backup-id "$HOSTNAME" --backup-time "$SELECTED_BACKUP"
  RESTORE_STATUS=$?

  if [ $RESTORE_STATUS -eq 0 ]; then
    whiptail --msgbox "Restauración completa realizada con éxito. Ahora se ejecutarán pasos de autoreparación (GRUB, kernel, DKMS)..." 10 70

    # Reparación post-restauración
    {
      echo "[INFO] Reinstalando GRUB en /dev/sda..."
      grub-install /dev/sda && update-grub

      echo "[INFO] Reinstalando kernel actual..."
      apt install --reinstall -y pve-kernel-$(uname -r)

      echo "[INFO] Reconstruyendo módulos DKMS..."
      dkms autoinstall || true
    } >> /var/log/proxmox-restore.log 2>&1

    whiptail --yesno "Restauración y autoreparación completadas.\n¿Deseas reiniciar ahora el sistema?" 10 60 && reboot
  else
    whiptail --msgbox "Error durante la restauración. Verifica los logs para más detalles." 10 60
  fi
}

restore_pbs_full
"""

pbs_autorepair_path.write_text(pbs_restore_autorepair_script)
pbs_autorepair_path.chmod(0o755)
pbs_autorepair_path