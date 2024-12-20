#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
CACHE_DIR="$BASE_DIR/cache"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
REMOTE_VERSION_FILE="$BASE_DIR/latest_version.txt"
LANGUAGE_FILE="/root/.proxmenux_language"
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false}

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Crear las carpetas necesarias
mkdir -p "$LANG_DIR" "$CACHE_DIR"

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

# Descargar el archivo de idioma si no existe
LANG_FILE="$LANG_DIR/$LANGUAGE.lang"
if [ ! -f "$LANG_FILE" ]; then
    msg_info "Descargando archivo de idioma..."
    wget -qO "$LANG_FILE" "$REPO_URL/lang/$LANGUAGE.lang"
    if [ $? -ne 0 ]; then
        msg_error "Error al cargar el archivo de idioma. Verifica la conexión a Internet o la URL."
        exit 1
    fi
else
    msg_ok "Archivo de idioma ya existe localmente."
fi

source "$LANG_FILE"

# Verificar si hay una nueva versión del menú
if [ "$SKIP_UPDATE_CHECK" = "false" ]; then
    msg_info "Comprobando actualizaciones..."
    if wget -qO "$REMOTE_VERSION_FILE" "$REPO_URL/version.txt"; then
        REMOTE_VERSION=$(cat "$REMOTE_VERSION_FILE" | tr -d '\r')

        # Comprobar si el archivo local de versión existe
        if [ ! -f "$LOCAL_VERSION_FILE" ]; then
            echo "$SCRIPT_VERSION" > "$LOCAL_VERSION_FILE"
        fi

        LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '\r')

        # Mostrar versiones para depuración
        msg_info "Versión local: $LOCAL_VERSION"
        msg_info "Versión remota: $REMOTE_VERSION"

        # Comparar versión local con remota
        if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
            whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60 && {
                wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"
                chmod +x /usr/local/bin/menu.sh
                echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
                whiptail --title "$UPDATE_COMPLETE" --msgbox "$UPDATE_MESSAGE" 10 60
                SKIP_UPDATE_CHECK=true exec env SKIP_UPDATE_CHECK=true /usr/local/bin/menu.sh
            }
        else
            msg_ok "El menú está actualizado."
        fi
    else
        msg_error "No se pudo comprobar la versión. Verifica la conexión a Internet o la URL del archivo."
    fi
fi

# Dependencias y bucle del menú
check_dependencies() {
    if ! command -v whiptail &> /dev/null; then
        msg_info "Instalando dependencias necesarias..."
        apt-get update
        apt-get install -y whiptail
        msg_ok "Dependencias instaladas."
    fi
}

show_menu() {
    # Aquí iría el menú principal
    msg_ok "ProxMenux está listo."
    exit 0
}

# Verificar dependencias y mostrar menú
check_dependencies
show_menu
