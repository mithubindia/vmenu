#!/bin/bash

# Configuración
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
INSTALL_DIR="/usr/local/bin"
MENU_SCRIPT="menu.sh"

# Verificar que se ejecute como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root." >&2
    exit 1
fi

# Descargar el script menu.sh desde GitHub
echo "Descargando el script principal..."
wget -qO "$INSTALL_DIR/$MENU_SCRIPT" "$REPO_URL/$MENU_SCRIPT"

# Verificar si la descarga fue exitosa
if [ $? -ne 0 ]; then
    echo "Error al descargar el script desde $REPO_URL. Verifica la URL y tu conexión a Internet." >&2
    exit 1
fi

# Asignar permisos de ejecución
chmod +x "$INSTALL_DIR/$MENU_SCRIPT"

# Confirmación
echo "ProxMenux ha sido instalado correctamente."
echo "Ejecuta 'menu.sh' como root para iniciar el menú."

# Finalizar
exit 0
