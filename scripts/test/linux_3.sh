#!/bin/bash

ISO_DIR="/var/lib/vz/template/iso"
mkdir -p "$ISO_DIR"

# Comprobar dependencias necesarias
REQUIRED_PACKAGES=(curl wget whiptail)
MISSING=""
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    dpkg -s $pkg &>/dev/null || MISSING+="$pkg "
done
if [ -n "$MISSING" ]; then
    echo "Instalando dependencias necesarias: $MISSING"
    apt update && apt install -y $MISSING
fi

# Menú combinado único con fuente de origen
DISTROS=(
  "Ubuntu 22.04 LTS Desktop       |Desktop      |ProxMenux|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-desktop-amd64.iso"
  "Ubuntu 20.04 LTS Desktop       |Desktop      |ProxMenux|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-desktop-amd64.iso"
  "Ubuntu 22.04 LTS Server (CLI)  |CLI          |ProxMenux|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  "Ubuntu 20.04 LTS Server (CLI)  |CLI          |ProxMenux|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
  "Debian 12 Gnome (Desktop)      |Desktop      |ProxMenux|https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-DVD-1.iso"
  "Debian 11 Gnome (Desktop)      |Desktop      |ProxMenux|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-dvd/debian-11.9.0-amd64-DVD-1.iso"
  "Debian 12 Netinst (CLI)        |CLI          |ProxMenux|https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
  "Debian 11 Netinst (CLI)        |CLI          |ProxMenux|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-cd/debian-11.9.0-amd64-netinst.iso"
  "Fedora Workstation 39          |Desktop      |ProxMenux|https://download.fedoraproject.org/pub/fedora/linux/releases/39/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-39-1.5.iso"
  "Fedora Workstation 38          |Desktop      |ProxMenux|https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso"
  "Rocky Linux 9.3 Gnome          |Desktop      |ProxMenux|https://download.rockylinux.org/pub/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-boot.iso"
  "Rocky Linux 8.9 Gnome          |Desktop      |ProxMenux|https://download.rockylinux.org/pub/rocky/8.9/isos/x86_64/Rocky-8.9-x86_64-boot.iso"
  "Linux Mint 21.3 Cinnamon       |Desktop      |ProxMenux|https://mirrors.edge.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
  "Linux Mint 21.2 Cinnamon       |Desktop      |ProxMenux|https://mirrors.edge.kernel.org/linuxmint/stable/21.2/linuxmint-21.2-cinnamon-64bit.iso"
  "openSUSE Leap 15.5             |Desktop      |ProxMenux|https://download.opensuse.org/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64.iso"
  "openSUSE Leap 15.4             |Desktop      |ProxMenux|https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64.iso"
  "Alpine Linux 3.19              |CLI          |ProxMenux|https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.1-x86_64.iso"
  "Kali Linux 2024.1              |Desktop      |ProxMenux|https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
  "Arch Linux (automatizado)      |Automatizado |Helper Scripts|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/archlinux-vm.sh"
  "Debian 12 (automatizado)       |Automatizado |Helper Scripts|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/debian-vm.sh"
  "Ubuntu 22.04 (automatizado)    |Automatizado |Helper Scripts|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/ubuntu2204-vm.sh"
  "Ubuntu 24.04 (automatizado)    |Automatizado |Helper Scripts|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/ubuntu2404-vm.sh"
  "Ubuntu 24.10 (automatizado)    |Automatizado |Helper Scripts|https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/ubuntu2410-vm.sh"
)

# Construir menú con columnas alineadas
MENU_OPTIONS=("HEADER" "Versión                            │ Tipo         │ Fuente")
INDEX=0
for entry in "${DISTROS[@]}"; do
  NAME=$(echo "$entry" | cut -d"|" -f1)
  TYPE=$(echo "$entry" | cut -d"|" -f2)
  SOURCE=$(echo "$entry" | cut -d"|" -f3)
  DISPLAY="${NAME} │ ${TYPE} │ ${SOURCE}"
  MENU_OPTIONS+=("$INDEX" "$DISPLAY")
  URLS[$INDEX]="$entry"
  ((INDEX++))
done

CHOICE=$(whiptail --title "Instalación Linux" \
  --menu "Selecciona la distribución que deseas instalar o descargar:" 25 100 20 \
  "${MENU_OPTIONS[@]}" \
  3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

SELECTED="${URLS[$CHOICE]}"
NAME=$(echo "$SELECTED" | cut -d"|" -f1)
TYPE=$(echo "$SELECTED" | cut -d"|" -f2)
SOURCE=$(echo "$SELECTED" | cut -d"|" -f3)
URL=$(echo "$SELECTED" | cut -d"|" -f4)

if [[ "$TYPE" == "Automatizado" ]]; then
  echo "Ejecutando script remoto para: $NAME"
  bash -c "$(curl -fsSL $URL)"
else
  FILENAME=$(basename "$URL")
  if [ -f "$ISO_DIR/$FILENAME" ]; then
    echo "ℹ️ La imagen ya existe: $ISO_DIR/$FILENAME"
  else
    echo "⬇️ Descargando $NAME..."
    wget -O "$ISO_DIR/$FILENAME" "$URL"
  fi
  echo "✅ Imagen lista: $ISO_DIR/$FILENAME"
fi