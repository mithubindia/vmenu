#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
INSTALL_DIR="/usr/local/bin"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu.sh"

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -e " ${YW}[INFO] $1${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Verificar que se ejecute como root
if [ "$(id -u)" -ne 0 ]; then
    msg_error "Este script debe ejecutarse como root."
    exit 1
fi

# Verificar dependencias
if ! command -v whiptail &> /dev/null; then
    msg_info "Instalando whiptail..."
    if apt-get update && apt-get install -y whiptail; then
        msg_ok "whiptail instalado correctamente."
    else
        msg_error "Error al instalar whiptail. Por favor, instálalo manualmente."
        exit 1
    fi
fi

# Crear las carpetas necesarias
msg_info "Creando carpetas necesarias..."
mkdir -p "$LANG_DIR"
msg_ok "Carpetas creadas."

# Descargar el script principal (menu.sh)
msg_info "Descargando el script principal..."
if wget -qO "$INSTALL_DIR/$MENU_SCRIPT" "$REPO_URL/$MENU_SCRIPT"; then
    chmod +x "$INSTALL_DIR/$MENU_SCRIPT"
    msg_ok "Script principal descargado."
else
    msg_error "Error al descargar el script principal. Verifica la URL y tu conexión a Internet."
    exit 1
fi

# Descargar la versión inicial
msg_info "Descargando archivo de versión..."
if wget -qO "$LOCAL_VERSION_FILE" "$REPO_URL/version.txt"; then
    msg_ok "Archivo de versión descargado."
else
    msg_error "Error al descargar el archivo de versión."
    exit 1
fi

# Confirmación
msg_ok "ProxMenux ha sido instalado correctamente."
msg_info "Ejecuta 'menu.sh' como root para iniciar el menú."

# Finalizar
exit 0
