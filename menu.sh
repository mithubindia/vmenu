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

# Descargar archivo de idioma por defecto (español) para mensajes iniciales
if [ ! -f "$LANG_DIR/es.lang" ]; then
    if ! wget -qO "$LANG_DIR/es.lang" "$REPO_URL/lang/es.lang"; then
        msg_error "Error al descargar el archivo de idioma inicial."
        exit 1
    fi
fi

# Cargar mensajes iniciales
source "$LANG_DIR/es.lang"

# Cargar o seleccionar idioma
load_language() {
    if [ ! -f "$LANGUAGE_FILE" ]; then
        select_language_first_time
    else
        LANGUAGE=$(cat "$LANGUAGE_FILE")
        LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
        if [ ! -f "$LANG_FILE" ]; then
            msg_info "$LANG_DOWNLOAD"
            if ! wget -qO "$LANG_FILE" "$REPO_URL/lang/$LANGUAGE.lang"; then
                msg_error "$LANG_DOWNLOAD_ERROR"
                exit 1
            fi
        fi
        source "$LANG_FILE"
        msg_info "$LANG_LOADED $LANGUAGE"
    fi
}

# Función para la primera selección de idioma
select_language_first_time() {
    LANGUAGE=$(whiptail --title "$INITIAL_LANG_SELECT" --menu "$INITIAL_LANG_PROMPT" 15 60 2 \
        "es" "Español" \
        "en" "English" 3>&1 1>&2 2>&3)

    if [ -z "$LANGUAGE" ]; then
        msg_error "$INITIAL_LANG_ERROR"
        exit 1
    fi

    LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
    if [ ! -f "$LANG_FILE" ]; then
        if ! wget -qO "$LANG_FILE" "$REPO_URL/lang/$LANGUAGE.lang"; then
            msg_error "$LANG_DOWNLOAD_ERROR"
            exit 1
        fi
    fi

    echo "$LANGUAGE" > "$LANGUAGE_FILE"
    source "$LANG_FILE"
    msg_ok "$LANG_SUCCESS $LANGUAGE"
}

# Función para cambiar idioma desde el menú
select_language() {
    LANGUAGE=$(whiptail --title "$LANG_SELECT" --menu "$LANG_PROMPT" 15 60 2 \
        "es" "Español" \
        "en" "English" 3>&1 1>&2 2>&3)

    if [ -z "$LANGUAGE" ]; then
        msg_error "$LANG_ERROR"
        return
    fi

    LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
    if [ ! -f "$LANG_FILE" ]; then
        msg_info "$LANG_DOWNLOAD"
        if ! wget -qO "$LANG_FILE" "$REPO_URL/lang/$LANGUAGE.lang"; then
            msg_error "$LANG_DOWNLOAD_ERROR"
            return
        fi
    fi

    echo "$LANGUAGE" > "$LANGUAGE_FILE"
    msg_ok "$LANG_SUCCESS $LANGUAGE"
    exec "$0"
}

# Verificar actualizaciones
check_updates() {
    if wget -qO "$REMOTE_VERSION_FILE" "$REPO_URL/version.txt"; then
        REMOTE_VERSION=$(cat "$REMOTE_VERSION_FILE" | tr -d '\r')

        if [ ! -f "$LOCAL_VERSION_FILE" ]; then
            echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
            msg_info "$FIRST_INSTALL $REMOTE_VERSION"
        else
            LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '\r')

            if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
                msg_info "$UPDATE_CHECKING"
                if [ "$(printf '%s\n' "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | tail -n1)" = "$REMOTE_VERSION" ]; then
                    if whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60; then
                        perform_update
                    else
                        msg_info "$UPDATE_POSTPONED"
                    fi
                else
                    msg_info "$UPDATE_CURRENT"
                fi
            else
                msg_info "$UPDATE_CURRENT"
            fi
        fi
    else
        msg_error "$UPDATE_CHECK_ERROR"
    fi
}

# Función para realizar la actualización
perform_update() {
    if wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"; then
        chmod +x /usr/local/bin/menu.sh
        echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
        msg_ok "$UPDATE_MESSAGE"
        exec /usr/local/bin/menu.sh
    else
        msg_error "$UPDATE_ERROR"
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

# Mostrar menú de configuración
show_config_menu() {
    while true; do
        OPTION=$(whiptail --title "$CONFIG_TITLE" --menu "$SELECT_OPTION" 15 60 2 \
            "1" "$LANG_OPTION" \
            "2" "$UNINSTALL_OPTION" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                select_language
                ;;
            2)
                uninstall_proxmenu
                ;;
            *)
                return
                ;;
        esac
    done
}

# Mostrar menú principal
show_menu() {
    while true; do
        OPTION=$(whiptail --title "$MAIN_MENU_TITLE" --menu "$SELECT_OPTION" 15 60 4 \
            "1" "$OPTION_1" \
            "2" "$OPTION_2" \
            "3" "$OPTION_3" \
            "4" "$EXIT_MENU" 3>&1 1>&2 2>&3)

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
                msg_info "$NETWORK_REPAIR_RUNNING"
                if wget -qO- "$REPO_URL/scripts/repair_network.sh" | bash; then
                    msg_ok "$NETWORK_REPAIR_SUCCESS"
                else
                    msg_error "$NETWORK_REPAIR_ERROR"
                fi
                ;;
            3)
                show_config_menu
                ;;
            4)
                msg_ok "$EXIT_MESSAGE"
                exit 0
                ;;
            *)
                msg_error "$INVALID_OPTION"
                sleep 2
                ;;
        esac
    done
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
load_language
check_updates
show_menu
