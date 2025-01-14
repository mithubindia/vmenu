#!/bin/bash

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 1. Seleccionar VM
VMID=$(whiptail --title "Seleccionar VM" --menu "Selecciona la VM a la que deseas añadir discos:" 15 60 8 $(qm list | awk 'NR>1 {print $1, $2}') 3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
    echo -e "${RED}Operación cancelada.${NC}"
    exit 1
fi

# 2. Detectar disco del sistema y listar discos físicos disponibles
DISCO_SISTEMA=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
DISCOS=$(lsblk -d -n -e 7,11 | awk '{print $1}' | grep -v "${DISCO_SISTEMA##*/}" | sed 's/^/\/dev\//')
SELECCIONADOS=$(whiptail --title "Seleccionar Discos" --checklist "Selecciona los discos que deseas añadir:" 20 60 10 $(for disco in $DISCOS; do echo "$disco" OFF; done) 3>&1 1>&2 2>&3)

if [ -z "$SELECCIONADOS" ]; then
    echo -e "${RED}No se seleccionaron discos.${NC}"
    exit 1
fi

# 3. Seleccionar tipo de interfaz
INTERFAZ=$(whiptail --title "Tipo de Interfaz" --menu "Selecciona el tipo de interfaz:" 15 40 4 \
    "sata" "Añadir como SATA" \
    "scsi" "Añadir como SCSI" \
    "virtio" "Añadir como VirtIO" \
    "ide" "Añadir como IDE" 3>&1 1>&2 2>&3)

if [ -z "$INTERFAZ" ]; then
    echo -e "${RED}No se seleccionó una interfaz.${NC}"
    exit 1
fi

# 4. Confirmación
whiptail --title "Confirmación" --yesno "VMID: $VMID\nDiscos seleccionados: $SELECCIONADOS\nInterfaz: $INTERFAZ\n\n¿Deseas proceder?" 15 50
if [ $? -ne 0 ]; then
    echo -e "${RED}Operación cancelada.${NC}"
    exit 1
fi

# 5. Añadir los discos
echo -e "${GREEN}Añadiendo discos...${NC}"
DISK_INDEX=0
for DISCO in $SELECCIONADOS; do
    qm set "$VMID" -$INTERFAZ$DISK_INDEX "$DISCO"
    ((DISK_INDEX++))
done

echo -e "${GREEN}Los discos se añadieron correctamente.${NC}"

exit 0
