#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
REMOTE_VERSION_FILE="$BASE_DIR/latest_version.txt"
LANGUAGE_FILE="/root/.proxmenux_language"

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -e " ${YW}[INFO] $1${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Crear directorios necesarios
mkdir -p "$LANG_DIR"

# Seleccionar idioma en la primera ejecución
if [ ! -f "$LANGUAGE_FILE" ]; then
    LANGUAGE=$(whiptail --title "$LANG_SELECT" --menu "$LANG_PROMPT" 15 60 2 \
        "es" "Español" \
        "en" "English" 3>&1 1>&2 2>&3)

    if [ -z "$LANGUAGE" ]; then
        msg_error "$LANG_ERROR"
        exit 1
    fi

    echo "$LANGUAGE" > "$LANGUAGE_FILE"
    msg_ok "$LANG_SUCCESS $LANGUAGE"
else
    LANGUAGE=$(cat "$LANGUAGE_FILE")
    msg_info "$LANG_LOADED $LANGUAGE"
fi

# Descargar archivo de idioma si no existe
LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
if [ ! -f "$LANG_FILE" ]; then
    msg_info "$LANG_DOWNLOAD"
    if ! wget -qO "$LANG_FILE" "$REPO_URL/lang/$LANGUAGE.lang"; then
        msg_error "$LANG_DOWNLOAD_ERROR"
        exit 1
    fi
else
    msg_ok "$LANG_EXISTS"
fi

# Cargar archivo de idioma
source "$LANG_FILE"

# Verificar actualizaciones
check_updates() {
    msg_info "$UPDATE_CHECKING"
    if wget -qO "$REMOTE_VERSION_FILE" "$REPO_URL/version.txt"; then
        REMOTE_VERSION=$(cat "$REMOTE_VERSION_FILE" | tr -d '\r')

        if [ ! -f "$LOCAL_VERSION_FILE" ]; then
            # Si es la primera instalación, usar la versión del repositorio
            echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
            msg_info "$FIRST_INSTALL $REMOTE_VERSION"
        else
            LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '\r')

            if [ "$(printf '%s\n' "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | tail -n1)" = "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
                if whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60; then
                    if wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"; then
                        chmod +x /usr/local/bin/menu.sh
                        echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
                        msg_ok "$UPDATE_MESSAGE"
                        exec /usr/local/bin/menu.sh
                    else
                        msg_error "$UPDATE_ERROR"
                    fi
                else
                    msg_info "$UPDATE_POSTPONED"
                fi
            else
                msg_ok "$UPDATE_CURRENT"
            fi
        fi
    else
        msg_error "$UPDATE_CHECK_ERROR"
    fi
}

# Función para desinstalar ProxMenu
uninstall_proxmenu() {
    if whiptail --title "$UNINSTALL_TITLE" --yesno "$UNINSTALL_CONFIRM" 10 60; then
        msg_info "$UNINSTALL_PROCESS"
        rm -rf "$BASE_DIR"
        rm -f "/usr/local/bin/menu.sh"
        rm -f "$LANGUAGE_FILE"
        msg_ok "$UNINSTALL_COMPLETE"
        exit 0
    fi
}

# Mostrar menú principal
show_menu() {
    OPTION=$(whiptail --title "$MENU_TITLE" --menu "$SELECT_OPTION" 15 60 2 \
        "1" "$OPTION_1" \
        "2" "$OPTION_2" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            msg_info "$SCRIPT_RUNNING"
            if wget -qO- "$REPO_URL/scripts/igpu_tpu.sh" | bash; then
                msg_ok "$SCRIPT_SUCCESS"
            else
                msg_error "$SCRIPT_ERROR"
            fi
            ;;
        2)
            uninstall_proxmenu
            ;;
        *)
            # Si el usuario presiona Cancelar o Esc
            msg_ok "$EXIT_MESSAGE"
            exit 0
            ;;
    esac
}

# Verificar dependencias
if ! command -v whiptail &> /dev/null; then
    msg_info "$DEPS_INSTALLING"
    if apt-get update && apt-get install -y whiptail; then
        msg_ok "$DEPS_SUCCESS"
    else
        msg_error "$DEPS_ERROR"
        exit 1
    fi
fi

# Flujo principal
check_updates
while true; do
    show_menu
done

