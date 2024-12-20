#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
REMOTE_VERSION_FILE="$BASE_DIR/latest_version.txt"
LANGUAGE_FILE="/root/.proxmenux_language"
MENU_TITLE="ProxMenux - Menú Principal"
SKIP_UPDATE_CHECK=${SKIP_UPDATE_CHECK:-false}

# Colores para salida
YW="\033[33m"; GN="\033[1;92m"; RD="\033[01;31m"; CL="\033[m"
msg_info() { echo -ne " ${YW}[INFO] $1...${CL}"; }
msg_ok() { echo -e " ${GN}[OK] $1${CL}"; }
msg_error() { echo -e " ${RD}[ERROR] $1${CL}"; }

# Crear carpetas necesarias
mkdir -p "$LANG_DIR"

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

# Descargar archivo de idioma si no existe
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

# Verificar actualizaciones del menú
if [ "$SKIP_UPDATE_CHECK" = "false" ]; then
    msg_info "Comprobando actualizaciones..."
    if wget -qO "$REMOTE_VERSION_FILE" "$REPO_URL/version.txt"; then
        REMOTE_VERSION=$(cat "$REMOTE_VERSION_FILE" | tr -d '\r')

        if [ ! -f "$LOCAL_VERSION_FILE" ]; then
            echo "1.0.0" > "$LOCAL_VERSION_FILE"
        fi

        LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE" | tr -d '\r')

        if [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
            whiptail --title "Actualización Disponible" --yesno "Hay una nueva versión. ¿Actualizar ahora?" 10 60 && {
                wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"
                chmod +x /usr/local/bin/menu.sh
                echo "$REMOTE_VERSION" > "$LOCAL_VERSION_FILE"
                exec /usr/local/bin/menu.sh
            }
        else
            msg_ok "El menú está actualizado."
        fi
    else
        msg_error "No se pudo comprobar la versión. Continuando sin actualizar..."
    fi
fi

# Verificar dependencias
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
    OPTION=$(whiptail --title "$MENU_TITLE" --menu "Selecciona una opción:" 15 60 4 \
        "1" "Añadir HW iGPU" \
        "2" "Añadir Coral TPU + HW iGPU" \
        "3" "Salir" 3>&1 1>&2 2>&3)

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
            msg_ok "¡Hasta luego!"
            exit 0
            ;;
        *)
            msg_error "Opción no válida."
            ;;
    esac
}

# Dependencias y bucle del menú
check_dependencies
while true; do
    show_menu
done
