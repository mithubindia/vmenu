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

# Menú principal para elegir familia de Windows
FAMILY=$(whiptail --title "Tipo de Windows" \
    --menu "Selecciona qué tipo de Windows deseas descargar:" 15 60 4 \
    "w11" "Windows 11" \
    "w10" "Windows 10" \
    "srv" "Windows Server" \
    3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

# Parámetros de búsqueda según la familia seleccionada
case $FAMILY in
    w11)
        SEARCH_TERM="windows 11"
        TITLE_MENU="Windows 11"
        ;;
    w10)
        SEARCH_TERM="windows 10"
        TITLE_MENU="Windows 10"
        ;;
    srv)
        SEARCH_TERM="windows server"
        TITLE_MENU="Windows Server"
        ;;
    *)
        echo "Selección inválida"
        exit 1
        ;;
esac

# Obtener lista dinámica de builds desde UUP dump API
API_URL="https://api.uupdump.net/listid.php?search=$(echo $SEARCH_TERM | sed 's/ /+/g')&arch=x64&ring=retail"
VERSIONS=$(curl -s "$API_URL" | jq -r '.response[] | [.title, .build, .arch] | @tsv' | head -n 10)

# Construir menú dinámico
MENU_OPTIONS=()
INDEX=0
while IFS=$'\t' read -r TITLE BUILD ARCH; do
    DISPLAY_NAME="$TITLE ($BUILD)"
    MENU_OPTIONS+=("$INDEX" "$DISPLAY_NAME")
    VERSION_DATA[$INDEX]="$TITLE|$BUILD|$ARCH|es-es"
    ((INDEX++))
done <<< "$VERSIONS"

CHOICE=$(whiptail --title "Descarga de ISO $TITLE_MENU" \
    --menu "Elige una versión para generar la ISO:" 20 78 10 \
    "${MENU_OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

# Obtener datos seleccionados
SELECTED="${VERSION_DATA[$CHOICE]}"
NAME=$(echo "$SELECTED" | cut -d"|" -f1)
BUILD=$(echo "$SELECTED" | cut -d"|" -f2)
ARCH=$(echo "$SELECTED" | cut -d"|" -f3)
LANG=$(echo "$SELECTED" | cut -d"|" -f4)

# Consultar API para obtener ID de descarga
API_URL="https://api.uupdump.net/listid.php?search=$(echo $NAME | sed 's/ /+/g')&arch=$ARCH&ring=retail"

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
