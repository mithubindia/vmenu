#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
SCRIPT_VERSION="1.0.0"  # Versión actual del menú
VERSION_FILE="/tmp/proxmenux_version"
LANGUAGE_FILE="/root/.proxmenux_language"
DEFAULT_LANGUAGE="es"
TEMP_LANG_FILE="/tmp/proxmenux_lang"

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Verificar idioma seleccionado o configurarlo
if [ ! -f "$LANGUAGE_FILE" ]; then
    echo "Idioma predeterminado: Español (es)"
    echo "$DEFAULT_LANGUAGE" > "$LANGUAGE_FILE"
fi

LANGUAGE=$(cat "$LANGUAGE_FILE")
LANG_PATH="$REPO_URL/lang/$LANGUAGE.lang"

# Descargar archivo de idioma
wget -qO "$TEMP_LANG_FILE" "$LANG_PATH"
if [ $? -ne 0 ]; then
    echo "Error al cargar el archivo de idioma. Asegúrate de que tienes conexión a Internet." >&2
    exit 1
fi
source "$TEMP_LANG_FILE"

# Verificar si hay una nueva versión del menú
msg_info "Comprobando actualizaciones..."
wget -qO "$VERSION_FILE" "$REPO_URL/version.txt"
if [ $? -eq 0 ]; then
    REMOTE_VERSION=$(cat "$VERSION_FILE")
    if [ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]; then
        whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60 && {
            wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"
            chmod +x /usr/local/bin/menu.sh
            whiptail --title "$UPDATE_COMPLETE" --msgbox "$UPDATE_MESSAGE" 10 60
            exec /usr/local/bin/menu.sh
        }
    fi
else
    msg_error "No se pudo comprobar la versión. Continuando sin actualizar..."
fi

# Función para verificar dependencias
check_dependencies() {
    if ! command -v whiptail &> /dev/null; then
        msg_info "Instalando dependencias necesarias..."
        apt-get update
        apt-get install -y whiptail
        msg_ok "Dependencias instaladas."
    fi
}

# Mostrar menú principal
show_menu() {
    OPTION=$(whiptail --title "$MENU_TITLE" --menu "$SELECT_OPTION" 15 60 4 \
        "1" "$OPTION_1" \
        "2" "$OPTION_2" \
        "3" "$EXIT" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            msg_info "Ejecutando script para HW iGPU..."
            wget -qO- "$REPO_URL/scripts/add_hw_acceleration_lxc.sh" | bash
            ;;
        2)
            msg_info "Ejecutando script para Coral TPU + HW iGPU..."
            wget -qO- "$REPO_URL/scripts/add_coral_tpu_lxc.sh" | bash
            wget -qO- "$REPO_URL/scripts/add_hw_acceleration_lxc.sh" | bash
            ;;
        3)
            msg_ok "$BYE_MESSAGE"
            exit 0
            ;;
        *)
            msg_error "$INVALID_OPTION"
            ;;
    esac
}

# Dependencias y bucle del menú
check_dependencies
while true; do
    show_menu
done
