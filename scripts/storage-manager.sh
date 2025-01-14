#!/bin/bash

DUMP_DIR="/var/lib/vz/dump"
STORAGE_CFG="/etc/pve/storage.cfg"

# Función para comprobar y reparar después de la restauración
reparar_storage_cfg() {
    whiptail --title "Comprobación de Almacenamientos" --msgbox "Comprobando consistencia de los volúmenes de almacenamiento..." 8 40

    # Verificar grupos LVM
    VG_LIST=$(vgs --noheadings -o vg_name)
    while read -r LINE; do
        if [[ "$LINE" =~ vgname ]]; then
            VG_NAME=$(echo "$LINE" | awk '{print $NF}')
            if ! echo "$VG_LIST" | grep -q "$VG_NAME"; then
                echo "El volumen $VG_NAME no existe, eliminando entrada..."
                sed -i "/vgname $VG_NAME/,/nodes/d" "$STORAGE_CFG"
            fi
        fi
    done < "$STORAGE_CFG"

    whiptail --title "Reparación Completada" --msgbox "La comprobación de consistencia ha finalizado. Se eliminaron las entradas no válidas." 8 40
}

# Restaurar copia de seguridad y comprobar
restaurar_backup() {
    BACKUP_FILE=$(whiptail --title "Seleccionar Copia de Seguridad" --menu "Selecciona la copia de seguridad a restaurar:" 15 60 8 $(ls "$DUMP_DIR"/storage.cfg_*.bak) 3>&1 1>&2 2>&3)

    if [ -z "$BACKUP_FILE" ]; then
        whiptail --title "Error" --msgbox "No se seleccionó ninguna copia de seguridad." 8 40
        exit 1
    fi

    cp "$BACKUP_FILE" "$STORAGE_CFG"
    whiptail --title "Restauración Completada" --msgbox "Se ha restaurado el archivo storage.cfg desde la copia de seguridad: $BACKUP_FILE" 8 40

    reparar_storage_cfg
}

# Menú principal
OPTION=$(whiptail --title "Gestor de Storage.cfg" --menu "Selecciona una opción:" 15 60 3 \
    "1" "Realizar copia de seguridad del archivo storage.cfg" \
    "2" "Restaurar copia de seguridad y comprobar consistencia" \
    "3" "Reparar archivo storage.cfg si se han cambiado discos" 3>&1 1>&2 2>&3)

case $OPTION in
    1)
        BACKUP_FILE="${DUMP_DIR}/storage.cfg_$(date +%Y%m%d%H%M%S).bak"
        cp "$STORAGE_CFG" "$BACKUP_FILE"
        whiptail --title "Copia de Seguridad" --msgbox "Se ha creado una copia de seguridad en: $BACKUP_FILE" 8 40
        ;;
    2)
        restaurar_backup
        ;;
    3)
        reparar_storage_cfg
        ;;
    *)
        exit 0
        ;;
esac
