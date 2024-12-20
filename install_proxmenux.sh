#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
INSTALL_DIR="/usr/local/bin"
BASE_DIR="/usr/local/share/proxmenux"
LANG_DIR="$BASE_DIR/lang"
LOCAL_VERSION_FILE="$BASE_DIR/version.txt"
MENU_SCRIPT="menu.sh"

# Verificar que se ejecute como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root." >&2
    exit 1
fi

# Crear las carpetas necesarias
echo "Creando carpetas necesarias..."
mkdir -p "$LANG_DIR"

# Descargar el script principal (menu.sh)
echo "Descargando el script principal..."
wget -qO "$INSTALL_DIR/$MENU_SCRIPT" "$REPO_URL/$MENU_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Error al descargar el script principal. Verifica la URL y tu conexión a Internet." >&2
    exit 1
fi

# Descargar archivos de idioma
echo "Descargando archivos de idioma..."
for LANG in es en; do
    wget -qO "$LANG_DIR/$LANG.lang" "$REPO_URL/lang/$LANG.lang"
    if [ $? -ne 0 ]; then
        echo "Error al descargar el archivo de idioma '$LANG.lang'. Verifica la URL y tu conexión a Internet." >&2
        exit 1
    fi
done

# Descargar la versión inicial
echo "Descargando archivo de versión inicial..."
wget -qO "$LOCAL_VERSION_FILE" "$REPO_URL/version.txt"
if [ $? -ne 0 ]; then
    echo "Error al descargar el archivo de versión. Verifica la URL y tu conexión a Internet." >&2
    exit 1
fi

# Asignar permisos de ejecución al script principal
chmod +x "$INSTALL_DIR/$MENU_SCRIPT"

# Confirmación
echo "ProxMenux ha sido instalado correctamente."
echo "Ejecuta 'menu.sh' como root para iniciar el menú."

# Finalizar
exit 0
