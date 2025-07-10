#!/usr/bin/env bash

# ProxMenux - Windows ISO Creator from UUP Dump

BASE_DIR="/usr/local/share/vmenu"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache

function run_uupdump_creator() {

clear
show_proxmenux_logo

# Configuración de carpetas
TMP_DIR="/root/uup-temp"
OUT_DIR="/var/lib/vz/template/iso"
CONVERTER="/root/uup-converter"

mkdir -p "$TMP_DIR" "$OUT_DIR"
cd "$TMP_DIR" || exit 1

# Solicitar URL UUP Dump al usuario
UUP_URL=$(whiptail --inputbox "$(translate "Paste the UUP Dump URL here")" 10 90 3>&1 1>&2 2>&3)
[[ $? -ne 0 ]] && msg_error "$(translate "Cancelled by user.")" && exit 1

# Validar que la URL tenga los parámetros necesarios
if [[ ! "$UUP_URL" =~ id=.+\&pack=.+\&edition=.+ ]]; then
  msg_error "$(translate "The URL does not contain the required parameters (id, pack, edition).")"
  exit 1
fi

# Extraer parámetros de la URL
BUILD_ID=$(echo "$UUP_URL" | grep -oP 'id=\K[^&]+')
LANG=$(echo "$UUP_URL" | grep -oP 'pack=\K[^&]+')
EDITION=$(echo "$UUP_URL" | grep -oP 'edition=\K[^&]+')
ARCH="amd64"

echo -e "\n${BGN}=============== UUP Dump Creator ===============${CL}"
echo -e "    ${BGN}🆔 ID:${CL} ${DGN}$BUILD_ID${CL}"
echo -e "    ${BGN}🌐 Language:${CL} ${DGN}$LANG${CL}"
echo -e "    ${BGN}💿 Edition:${CL} ${DGN}$EDITION${CL}"
echo -e "    ${BGN}🖥️ Architecture:${CL} ${DGN}$ARCH${CL}"
echo -e "${BGN}===============================================${CL}\n"

# Descargar el conversor si no existe
if [[ ! -f "$CONVERTER/convert.sh" ]]; then
  echo "📦 $(translate "Downloading UUP converter...")"
  mkdir -p "$CONVERTER"
  cd "$CONVERTER" || exit 1
  wget -q https://git.uupdump.net/uup-dump/converter/archive/refs/heads/master.tar.gz -O converter.tar.gz
  tar -xzf converter.tar.gz --strip-components=1
  chmod +x convert.sh
  cd "$TMP_DIR" || exit 1
fi

# Crear script de descarga uup_download_linux.sh
cat > uup_download_linux.sh <<EOF
#!/bin/bash
mkdir -p files
echo "https://git.uupdump.net/uup-dump/converter/archive/refs/heads/master.tar.gz" > files/converter_multi

for prog in aria2c cabextract wimlib-imagex chntpw; do
  which \$prog &>/dev/null || { echo "\$prog not found."; exit 1; }
done
which genisoimage &>/dev/null || which mkisofs &>/dev/null || { echo "genisoimage/mkisofs not found."; exit 1; }

destDir="UUPs"
tempScript="aria2_script.\$RANDOM.txt"

aria2c --no-conf --console-log-level=warn --log-level=info --log="aria2_download.log" \
  -x16 -s16 -j2 --allow-overwrite=true --auto-file-renaming=false -d"files" -i"files/converter_multi" || exit 1

aria2c --no-conf --console-log-level=warn --log-level=info --log="aria2_download.log" \
  -o"\$tempScript" --allow-overwrite=true --auto-file-renaming=false \
  "https://uupdump.net/get.php?id=$BUILD_ID&pack=$LANG&edition=$EDITION&aria2=2" || exit 1

grep '#UUPDUMP_ERROR:' "\$tempScript" && { echo "❌ Error generating UUP download list."; exit 1; }

aria2c --no-conf --console-log-level=warn --log-level=info --log="aria2_download.log" \
  -x16 -s16 -j5 -c -R -d"\$destDir" -i"\$tempScript" || exit 1
EOF

chmod +x uup_download_linux.sh

# Ejecutar la descarga de archivos UUP
./uup_download_linux.sh

# Buscar carpeta UUPs descargada
UUP_FOLDER=$(find "$TMP_DIR" -type d -name "UUPs" | head -n1)
[[ -z "$UUP_FOLDER" ]] && msg_error "$(translate "No UUP folder found.")" && exit 1

# Iniciar conversión a ISO
echo -e "\n${GN}=======================================${CL}"
echo -e "    💿 ${GN}Starting ISO conversion...${CL}"
echo -e "${GN}=======================================${CL}\n"

"$CONVERTER/convert.sh" wim "$UUP_FOLDER" 1

# Buscar la ISO generada
ISO_FILE=$(find "$TMP_DIR" "$CONVERTER" "$UUP_FOLDER" -maxdepth 1 -iname "*.iso" | head -n1)
if [[ -f "$ISO_FILE" ]]; then
  mv "$ISO_FILE" "$OUT_DIR/"
  msg_ok "$(translate "ISO created successfully:") $OUT_DIR/$(basename "$ISO_FILE")"

  # Limpiar temporales
  msg_ok "$(translate "Cleaning temporary files...")"
  rm -rf "$TMP_DIR" "$CONVERTER"

  export LANGUAGE=C
  export LANG=C
  export LC_ALL=C
  load_language
  initialize_cache

  msg_success "$(translate "Press Enter to return to menu...")"
  read -r
else
  msg_warn "$(translate "No ISO was generated.")"

  export LANGUAGE=C
  export LANG=C
  export LC_ALL=C
  load_language
  initialize_cache

  msg_success "$(translate "Press Enter to return to menu...")"
  read -r
fi

}