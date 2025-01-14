#!/bin/bash

# Ruta donde están las imágenes de disco
IMAGES_DIR="/var/lib/vz/template/images/"

# Mensaje inicial
if ! [ -d "$IMAGES_DIR" ]; then
    mkdir -p "$IMAGES_DIR"
fi

whiptail --title "Importar Imagen de Disco" --msgbox "Por favor, asegúrate de tener las imágenes de disco que quieres importar en la siguiente ubicación:\n\n$IMAGES_DIR\n\nFormatos soportados: .img, .qcow2, .vmdk." 12 60

# 1. Seleccionar VM
VM_LIST=$(qm list | awk 'NR>1 {print $1, $2}')
if [ -z "$VM_LIST" ]; then
    whiptail --title "Error" --msgbox "No hay VMs disponibles en el sistema." 8 40
    exit 1
fi

VMID=$(whiptail --title "Seleccionar VM" --menu "Selecciona la VM a la que deseas importar la imagen de disco:" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    whiptail --title "Error" --msgbox "No se seleccionó ninguna VM." 8 40
    exit 1
fi

# 2. Seleccionar las imágenes de disco
IMAGENES=$(whiptail --title "Seleccionar Imágenes de Disco" --checklist "Selecciona las imágenes de disco para importar:" 20 60 10 $(ls "$IMAGES_DIR" | grep -E "\.(img|qcow2|vmdk)$" | awk '{print $1, "OFF"}') 3>&1 1>&2 2>&3)

if [ -z "$IMAGENES" ]; then
    whiptail --title "Error" --msgbox "No se seleccionó ninguna imagen." 8 40
    exit 1
fi

# 3. Importar cada imagen seleccionada
for IMAGEN in $IMAGENES; do
    # Quitar comillas de la imagen seleccionada
    IMAGEN=$(echo "$IMAGEN" | tr -d '"')

    # 4. Seleccionar tipo de disco para cada imagen
    INTERFAZ=$(whiptail --title "Tipo de Interfaz" --menu "Selecciona el tipo de disco para la imagen: $IMAGEN" 15 40 4 \
        "sata" "Añadir como SATA" \
        "scsi" "Añadir como SCSI" \
        "virtio" "Añadir como VirtIO" \
        "ide" "Añadir como IDE" 3>&1 1>&2 2>&3)

    if [ -z "$INTERFAZ" ]; then
        whiptail --title "Error" --msgbox "No se seleccionó un tipo de disco para $IMAGEN." 8 40
        exit 1
    fi

    FULL_PATH="$IMAGES_DIR/$IMAGEN"

    # 5. Añadir la imagen con índice automático
    INDEX=0

    # Buscar índice disponible
    while qm config "$VMID" | grep -q "${INTERFAZ}${INDEX}"; do
        ((INDEX++))
    done

    whiptail --title "Importando" --infobox "Importando imagen: $IMAGEN como ${INTERFAZ}${INDEX}..." 8 40
    qm importdisk "$VMID" "$FULL_PATH" "local-lvm" --format "$INTERFAZ"
    qm set "$VMID" -${INTERFAZ}${INDEX} "$FULL_PATH"
done

whiptail --title "Completado" --msgbox "Todas las imágenes se importaron correctamente." 8 40
exit 0
