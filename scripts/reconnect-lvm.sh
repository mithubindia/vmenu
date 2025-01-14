#!/bin/bash

# Mensaje inicial
whiptail --title "Reconectar discos en Proxmox" --msgbox "Este script te ayudará a reconectar los volúmenes LVM y LVM-thin en tu instalación de Proxmox recién restaurada." 12 60

# 1. Detectar grupos de volúmenes
VG_LIST=$(vgscan --ignorelockingfailure --reportformat json | jq -r '.report[0].vg[].vg_name')

if [ -z "$VG_LIST" ]; then
    whiptail --title "Error" --msgbox "No se detectaron grupos de volúmenes LVM en el sistema." 8 40
    exit 1
fi

# 2. Seleccionar grupo de volúmenes a activar
VG_SELECCIONADOS=$(whiptail --title "Seleccionar Grupos de Volúmenes" --checklist "Selecciona los grupos de volúmenes que deseas activar:" 20 60 10 $(for vg in $VG_LIST; do echo "$vg OFF"; done) 3>&1 1>&2 2>&3)

if [ -z "$VG_SELECCIONADOS" ]; then
    whiptail --title "Error" --msgbox "No se seleccionó ningún grupo de volúmenes." 8 40
    exit 1
fi

# 3. Activar los grupos de volúmenes seleccionados
for VG in $VG_SELECCIONADOS; do
    VG=$(echo "$VG" | tr -d '"')  # Eliminar comillas
    vgchange -ay "$VG"
done

whiptail --title "Volúmenes Activados" --msgbox "Los grupos de volúmenes seleccionados se activaron correctamente." 8 40

# 4. Escanear volúmenes en Proxmox
whiptail --title "Escanear VM" --infobox "Rescaneando las imágenes de disco y volúmenes..." 8 40
qm rescan

# 5. Mensaje final
whiptail --title "Finalizado" --msgbox "Los volúmenes y las imágenes de disco fueron reconocidos y están disponibles para usar en Proxmox." 8 40
exit 0
