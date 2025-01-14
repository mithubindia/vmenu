#!/bin/bash

DUMP_DIR="/var/lib/vz/dump"
STORAGE_CFG="/etc/pve/storage.cfg"

# Función para realizar copia de seguridad del archivo storage.cfg
backup_storage_cfg() {
    BACKUP_FILE="${DUMP_DIR}/storage.cfg_$(date +%Y%m%d%H%M%S).bak"
    cp "$STORAGE_CFG" "$BACKUP_FILE"
    whiptail --title "Copia de Seguridad" --msgbox "Se ha creado una copia de seguridad en: $BACKUP_FILE" 8 40
}

# Función para comprobar y reparar el archivo storage.cfg
reparar_storage_cfg() {
    whiptail --title "Comprobación de Almacenamientos" --msgbox "Comprobando consistencia de los volúmenes de almacenamiento..." 8 40

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

# Función para restaurar copia de seguridad del archivo storage.cfg
restaurar_backup() {
    BACKUP_FILE=$(whiptail --title "Seleccionar Copia de Seguridad" --menu "Selecciona la copia de seguridad a restaurar:" 15 60 8 $(ls "$DUMP_DIR"/storage.cfg_*.bak 2>/dev/null) 3>&1 1>&2 2>&3)

    if [ -z "$BACKUP_FILE" ]; then
        whiptail --title "Error" --msgbox "No se seleccionó ninguna copia de seguridad." 8 40
        exit 1
    fi

    cp "$BACKUP_FILE" "$STORAGE_CFG"
    whiptail --title "Restauración Completada" --msgbox "Se ha restaurado el archivo storage.cfg desde la copia de seguridad: $BACKUP_FILE" 8 40

    reparar_storage_cfg
}

# Función para reconectar los grupos de volúmenes
reconectar_volumenes() {
    whiptail --title "Reconectar discos en Proxmox" --msgbox "Este proceso activará los volúmenes LVM y LVM-thin en su sistema." 12 60

    VG_LIST=$(vgscan --ignorelockingfailure --reportformat json | jq -r '.report[0].vg[].vg_name')

    if [ -z "$VG_LIST" ]; then
        whiptail --title "Error" --msgbox "No se detectaron grupos de volúmenes LVM en el sistema." 8 40
        exit 1
    fi

    VG_SELECCIONADOS=$(whiptail --title "Seleccionar Grupos de Volúmenes" --checklist "Selecciona los grupos de volúmenes que deseas activar:" 20 60 10 $(for vg in $VG_LIST; do echo "$vg OFF"; done) 3>&1 1>&2 2>&3)

    if [ -z "$VG_SELECCIONADOS" ]; then
        whiptail --title "Error" --msgbox "No se seleccionó ningún grupo de volúmenes." 8 40
        exit 1
    fi

    for VG in $VG_SELECCIONADOS; do
        VG=$(echo "$VG" | tr -d '"')
        vgchange -ay "$VG"
    done

    whiptail --title "Volúmenes Activados" --msgbox "Los grupos de volúmenes seleccionados se activaron correctamente." 8 40

    whiptail --title "Escanear VM" --infobox "Rescaneando las imágenes de disco y volúmenes..." 8 40
    qm rescan

    whiptail --title "Finalizado" --msgbox "Los volúmenes y las imágenes de disco fueron reconocidos y están disponibles para usar en Proxmox." 8 40
}

# Menú principal
OPTION=$(whiptail --title "Gestor de Almacenamiento Proxmox" --menu "Selecciona una opción:" 15 60 4 \
    "1" "Realizar copia de seguridad del archivo storage.cfg" \
    "2" "Restaurar copia de seguridad y comprobar consistencia" \
    "3" "Reparar archivo storage.cfg si se han cambiado discos" \
    "4" "Reconectar grupos de volúmenes LVM/LVM-thin" 3>&1 1>&2 2>&3)

case $OPTION in
    1)
        backup_storage_cfg
        ;;
    2)
        restaurar_backup
        ;;
    3)
        reparar_storage_cfg
        ;;
    4)
        reconectar_volumenes
        ;;
    *)
        exit 0
        ;;
esac
