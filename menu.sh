#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
SCRIPT_VERSION="1.0.0"  # Versión actual del menú
VERSION_FILE="/tmp/proxmenux_version"
LANGUAGE_FILE="/root/.proxmenux_language"  # Archivo donde se guarda el idioma seleccionado
LANG_DIR="/usr/local/share/proxmenux/lang"
LANG_FILE="$LANG_DIR/selected.lang"
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false} # Control de reinicio

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Crear el directorio de idioma si no existe
if [ ! -d "$LANG_DIR" ]; then
    mkdir -p "$LANG_DIR"
fi

# Seleccionar idioma en la primera ejecución
if [ ! -f "$LANGUAGE_FILE" ]; then
    LANGUAGE=$(whiptail --title "Seleccionar Idioma" --menu "Elige tu idioma / Select your language:" 15 60 2 \
        "es" "Español" \
        "en" "English" 3>&1 1>&2 2>&3)

    if [ -z "$LANGUAGE" ]; then
        echo "No seleccionaste un idioma. Saliendo..." >&2
        exit 1
    fi

    echo "$LANGUAGE" > "$LANGUAGE_FILE"
    msg_ok "Idioma seleccionado: $LANGUAGE"
else
    LANGUAGE=$(cat "$LANGUAGE_FILE")
    msg_info "Idioma cargado: $LANGUAGE"
fi

# Descargar archivo de idioma
msg_info "Descargando archivo de idioma..."
LANG_PATH="$REPO_URL/lang/$LANGUAGE.lang"
wget -qO "$LANG_FILE" "$LANG_PATH"
if [ $? -ne 0 ]; then
    msg_error "Error al cargar el archivo de idioma. Verifica la conexión a Internet o la URL."
    exit 1
fi
source "$LANG_FILE"

# Verificar si hay una nueva versión del menú (solo si no se reinició)
if [ "$SKIP_UPDATE_CHECK" = "false" ]; then
    msg_info "Comprobando actualizaciones..."
    wget -qO "$VERSION_FILE" "$REPO_URL/version.txt"
    if [ $? -eq 0 ]; then
        REMOTE_VERSION=$(cat "$VERSION_FILE")
        if [ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]; then
            whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60 && {
                wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"
                chmod +x /usr/local/bin/menu.sh
                whiptail --title "$UPDATE_COMPLETE" --msgbox "$UPDATE_MESSAGE" 10 60
                SKIP_UPDATE_CHECK=true exec env SKIP_UPDATE_CHECK=true /usr/local/bin/menu.sh
            }
        fi
    else
        msg_error "No se pudo comprobar la versión. Continuando sin actualizar..."
    fi
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
