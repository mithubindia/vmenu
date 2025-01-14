#!/bin/bash

DUMP_DIR="/var/lib/vz/dump"
STORAGE_CFG="/etc/pve/storage.cfg"

# Crear directorio de dump si no existe
mkdir -p "$DUMP_DIR"

# Menú principal
OPTION=$(whiptail --title "Gestor de storage.cfg" --menu "Selecciona una opción:" 15 60 3 \
    "1" "Reparar storage.cfg" \
    "2" "Realizar copia de seguridad" \
    "3" "Recuperar copia de seguridad" 3>&1 1>&2 2>&3)

case $OPTION in
    1)
        # Reparar storage.cfg
        if [ -f "$STORAGE_CFG" ]; then
            mv "$STORAGE_CFG" "${STORAGE_CFG}.bak"
        fi
        echo "# Archivo de configuración de almacenamiento reparado automáticamente" > "$STORAGE_CFG"

        VG_LIST=$(vgs --noheadings -o vg_name)
        if [ -n "$VG_LIST" ]; then
            for VG in $VG_LIST; do
                echo -e "lvm-thin: local-lvm\n\tthinpool data\n\tvgname $VG\n\tcontent rootdir,images\n" >> "$STORAGE_CFG"
            done
        fi

        whiptail --title "Reparación completada" --msgbox "El archivo storage.cfg se ha reparado correctamente." 8 40
        ;;
    2)
        # Realizar copia de seguridad
        BACKUP_FILE="${DUMP_DIR}/storage.cfg_$(date +%Y%m%d%H%M%S).bak"
        cp "$STORAGE_CFG" "$BACKUP_FILE"
        whiptail --title "Copia de Seguridad" --msgbox "Se ha creado una copia de seguridad en: $BACKUP_FILE" 8 40
        ;;
    3)
        # Recuperar copia de seguridad
        BACKUP_LIST=$(ls "$DUMP_DIR"/storage.cfg_*.bak 2>/dev/null)
        if [ -z "$BACKUP_LIST" ]; then
            whiptail --title "Error" --msgbox "No se encontraron copias de seguridad." 8 40
            exit 1
        fi

        BACKUP_FILE=$(whiptail --title "Seleccionar Copia de Seguridad" --menu "Selecciona la copia de seguridad a recuperar:" 15 60 8 $(for file in $BACKUP_LIST; do echo "$file $(basename "$file")"; done) 3>&1 1>&2 2>&3)

        if [ -z "$BACKUP_FILE" ]; then
            whiptail --title "Error" --msgbox "No se seleccionó ninguna copia de seguridad." 8 40
            exit 1
        fi

        cp "$BACKUP_FILE" "$STORAGE_CFG"
        whiptail --title "Recuperación completada" --msgbox "Se ha restaurado el archivo storage.cfg desde la copia de seguridad: $BACKUP_FILE" 8 40
        ;;
    *)
        exit 0
        ;;
esac
