#!/bin/bash

# Definir la URL base del repositorio en GitHub
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts"

while true; do
    OPTION=$(whiptail --title "ProxMenu - Menú Principal" --menu "Seleccione una categoría:" 15 60 5 \
        "1" "Almacenamiento y discos duros" \
        "2" "Configuración" \
        "3" "Red y conexiones" \
        "4" "Salir" 3>&1 1>&2 2>&3)

    case $OPTION in
        1) bash <(curl -s "$REPO_URL/menu-almacenamiento.sh") ;;
        2) bash <(curl -s "$REPO_URL/menu-config.sh") ;;
        3) bash <(curl -s "$REPO_URL/menu-network.sh") ;;
        4) clear; exit 0 ;;
        *) msg_error "Opción inválida"; sleep 2 ;;
    esac
done
