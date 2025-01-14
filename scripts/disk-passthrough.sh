#!/bin/bash

# 1. Mostrar lista de VMs disponibles
VM_LIST=$(qm list | awk 'NR>1 {print $1, $2}')
if [ -z "$VM_LIST" ]; then
    whiptail --title "Error" --msgbox "No hay VMs disponibles en el sistema." 8 40
    exit 1
fi

# Seleccionar VM
VMID=$(whiptail --title "Seleccionar VM" --menu "Selecciona la VM a la que deseas añadir discos:" 15 60 8 $VM_LIST 3>&1 1>&2 2>&3)

if [ -z "$VMID" ]; then
    whiptail --title "Error" --msgbox "No se seleccionó ninguna VM." 8 40
    exit 1
fi

# 2. Detectar discos físicos disponibles excluyendo los asignados
DISCO_SISTEMA=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
DISCOS_LIBRES=$(lsblk -d -n -e 7,11 | awk '{print $1}' | grep -v "${DISCO_SISTEMA##*/}" | sed 's/^/\/dev\//' | while read DISCO; do
    if ! qm config | grep -q "$DISCO"; then
        INFO=$(lsblk -o NAME,MODEL,SIZE | grep "${DISCO##*/}")
        echo "$DISCO \"$INFO\" OFF"
    fi
done)

if [ -z "$DISCOS_LIBRES" ]; then
    whiptail --title "Error" --msgbox "No hay discos físicos disponibles para añadir." 8 40
    exit 1
fi

# Seleccionar discos
SELECCIONADOS=$(whiptail --title "Seleccionar Discos" --checklist "Selecciona los discos que deseas añadir:" 20 60 10 $DISCOS_LIBRES 3>&1 1>&2 2>&3)

if [ -z "$SELECCIONADOS" ]; then
    whiptail --title "Error" --msgbox "No se seleccionaron discos." 8 40
    exit 1
fi

# 3. Seleccionar tipo de interfaz
INTERFAZ=$(whiptail --title "Tipo de Interfaz" --menu "Selecciona el tipo de interfaz para los discos seleccionados:" 15 40 4 \
    "sata" "Añadir como SATA" \
    "scsi" "Añadir como SCSI" \
    "virtio" "Añadir como VirtIO" \
    "ide" "Añadir como IDE" 3>&1 1>&2 2>&3)

if [ -z "$INTERFAZ" ]; then
    whiptail --title "Error" --msgbox "No se seleccionó un tipo de interfaz." 8 40
    exit 1
fi

# 4. Añadir discos con índices automáticos
echo "Añadiendo discos..."
for DISCO in $SELECCIONADOS; do
    DISCO=$(echo "$DISCO" | tr -d '"')  # Eliminar comillas
    INDEX=0

    # Buscar índice disponible
    while qm config "$VMID" | grep -q "${INTERFAZ}${INDEX}"; do
        ((INDEX++))
    done

    qm set "$VMID" -${INTERFAZ}${INDEX} "$DISCO"
done

whiptail --title "Operación Completada" --msgbox "Los discos se añadieron correctamente a la VM $VMID." 8 40
exit 0
