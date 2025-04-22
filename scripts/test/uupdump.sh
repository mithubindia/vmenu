#!/bin/bash

# Ruta donde se guardarán las ISOs
ISO_DIR="/var/lib/vz/template/iso"
WORK_DIR="/root/uupdump"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || exit 1

# Comprobar dependencias necesarias
REQUIRED_PACKAGES=(aria2 cabextract wimtools chntpw genisoimage unzip curl jq whiptail)
MISSING=""
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    dpkg -s $pkg &>/dev/null || MISSING+="$pkg "
done
if [ -n "$MISSING" ]; then
    echo "Instalando dependencias necesarias: $MISSING"
    apt update && apt install -y $MISSING
fi

# Versiones predefinidas
VERSIONS=(
    "Win11_Pro_23H2|22631.1.230530-1536|x64|es-es"
    "Win10_LTSC_2021|19044.1288|x64|es-es"
    "Win_Server_2022|20348.1|x64|es-es"
)

# Crear menú con whiptail
MENU_OPTIONS=()
for i in "${!VERSIONS[@]}"; do
    NAME=$(echo "${VERSIONS[$i]}" | cut -d"|" -f1)
    MENU_OPTIONS+=("$i" "$NAME")
done

CHOICE=$(whiptail --title "Descarga de ISO Windows" \
    --menu "Elige una versión de Windows para generar la ISO:" 20 60 10 \
    "${MENU_OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

# Obtener datos seleccionados
SELECTED="${VERSIONS[$CHOICE]}"
NAME=$(echo "$SELECTED" | cut -d"|" -f1)
BUILD=$(echo "$SELECTED" | cut -d"|" -f2)
ARCH=$(echo "$SELECTED" | cut -d"|" -f3)
LANG=$(echo "$SELECTED" | cut -d"|" -f4)

# Consultar API para obtener ID de descarga
API_URL="https://api.uupdump.net/listid.php?search=$NAME&arch=$ARCH&ring=retail"

ID=$(curl -s "$API_URL" | jq -r ".response[] | select(.build == \"$BUILD\") | .uuid" | head -n1)

if [ -z "$ID" ]; then
    echo "No se encontró la versión en la API."
    exit 1
fi

# Descargar el ZIP de UUP dump
ZIP_URL="https://api.uupdump.net/getpkg.php?id=$ID&autodl=2"
ZIP_NAME="uupdump_$ID.zip"
curl -L "$ZIP_URL" -o "$ZIP_NAME"
unzip -o "$ZIP_NAME" -d "$WORK_DIR/$ID"
cd "$WORK_DIR/$ID" || exit 1
chmod +x uup_download_linux.sh

# Ejecutar generador de ISO
./uup_download_linux.sh

# Mover ISO generada
ISO_FILE=$(find . -type f -name "*.iso" | head -n1)
if [ -f "$ISO_FILE" ]; then
    mv "$ISO_FILE" "$ISO_DIR/"
    echo "✅ ISO generada y movida a: $ISO_DIR/$(basename "$ISO_FILE")"

    # Limpieza de archivos temporales
    echo "🧹 Limpiando archivos temporales..."
    rm -rf "$WORK_DIR/$ID"
    rm -f "$WORK_DIR/$ZIP_NAME"
    echo "✅ Limpieza completada."
else
    echo "❌ No se encontró la ISO generada."
    exit 1
fi
