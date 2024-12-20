#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
SCRIPT_VERSION="1.0.0"  # Versión actual del menú
VERSION_FILE="/tmp/proxmenux_version"
LANGUAGE_FILE="/root/.proxmenux_language"
DEFAULT_LANGUAGE="es"

# Verificar idioma seleccionado o configurarlo
if [ ! -f "$LANGUAGE_FILE" ]; then
    echo "Idioma predeterminado: Español (es)"
    echo "$DEFAULT_LANGUAGE" > "$LANGUAGE_FILE"
fi

LANGUAGE=$(cat "$LANGUAGE_FILE")
LANG_PATH="$REPO_URL/lang/$LANGUAGE.lang"

# Descargar archivo de idioma
TEMP_LANG_FILE="/tmp/proxmenux_lang"
wget -qO "$TEMP_LANG_FILE" "$LANG_PATH"
if [ $? -ne 0 ]; then
    echo "Error al cargar el archivo de idioma. Asegúrate de que tienes conexión a Internet." >&2
    exit 1
fi
source "$TEMP_LANG_FILE"

# Verificar si hay una nueva versión del menú
echo "Comprobando actualizaciones..."
wget -qO "$VERSION_FILE" "$REPO_URL/version.txt"
if [ $? -eq 0 ]; then
    REMOTE_VERSION=$(cat "$VERSION_FILE")
    if [ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]; then
        echo "$UPDATE_AVAILABLE"
        if whiptail --title "$UPDATE_TITLE" --yesno "$UPDATE_PROMPT" 10 60; then
            wget -qO /usr/local/bin/menu.sh "$REPO_URL/menu.sh"
            chmod +x /usr/local/bin/menu.sh
            whiptail --title "$UPDATE_COMPLETE" --msgbox "$UPDATE_MESSAGE" 10 60
            exec /usr/local/bin/menu.sh
        fi
    fi
else
    echo "No se pudo comprobar la versión. Continuando sin actualizar..."
fi

# Menú principal
while true; do
    OPTION=$(whiptail --title "$TITLE_MENU" --menu "$SELECT_OPTION" 15 60 9 \
        "1" "$OPTION_1" \
        "2" "$OPTION_2" \
        "3" "$OPTION_3" \
        "4" "$CHANGE_LANGUAGE" \
        "5" "$EXIT" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            # Ejecutar script desde GitHub
            wget -qO- "$REPO_URL/scripts/add_hw_acceleration_lxc.sh" | bash
            ;;
        2)
            wget -qO- "$REPO_URL/scripts/add_nvidia_vm.sh" | bash
            ;;
        3)
            wget -qO- "$REPO_URL/scripts/backup_proxmox.sh" | bash
            ;;
        4)
            # Cambiar idioma
            NEW_LANGUAGE=$(whiptail --title "$CHANGE_LANGUAGE_TITLE" --menu "$CHOOSE_LANGUAGE" 15 60 2 \
                "en" "English" \
                "es" "Español" 3>&1 1>&2 2>&3)
            if [ -n "$NEW_LANGUAGE" ]; then
                echo "$NEW_LANGUAGE" > "$LANGUAGE_FILE"
                LANGUAGE="$NEW_LANGUAGE"
                LANG_PATH="$REPO_URL/lang/$LANGUAGE.lang"
                wget -qO "$TEMP_LANG_FILE" "$LANG_PATH"
                source "$TEMP_LANG_FILE"
            fi
            ;;
        5)
            exit 0
            ;;
        *)
            whiptail --title "$ERROR" --msgbox "$INVALID_OPTION" 8 40
            ;;
    esac
done
