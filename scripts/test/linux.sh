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

# Preguntar si se desea ISO tradicional o Cloud-Init
ISO_TYPE=$(whiptail --title "Tipo de ISO Linux" \
  --menu "¿Qué tipo de imagen deseas descargar?" 15 60 4 \
  "tradicional" "ISO estándar (Desktop o Server)" \
  "cloud" "ISO Cloud-Init (uso avanzado)" \
  3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

if [ "$ISO_TYPE" = "tradicional" ]; then
  # Lista de distros estándar con múltiples versiones
  DISTROS=(
    "ubuntu_gui|Ubuntu 22.04 LTS Desktop|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-desktop-amd64.iso"
    "ubuntu_gui|Ubuntu 20.04 LTS Desktop|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-desktop-amd64.iso"
    "ubuntu_cli|Ubuntu 22.04 LTS Server (CLI)|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
    "ubuntu_cli|Ubuntu 20.04 LTS Server (CLI)|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
    "debian_gui|Debian 12 Gnome (Desktop)|https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-DVD-1.iso"
    "debian_gui|Debian 11 Gnome (Desktop)|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-dvd/debian-11.9.0-amd64-DVD-1.iso"
    "debian_cli|Debian 12 Netinst (CLI)|https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
    "debian_cli|Debian 11 Netinst (CLI)|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-cd/debian-11.9.0-amd64-netinst.iso"
    "fedora_gui|Fedora Workstation 39 (Desktop)|https://download.fedoraproject.org/pub/fedora/linux/releases/39/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-39-1.5.iso"
    "fedora_gui|Fedora Workstation 38 (Desktop)|https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso"
    "rocky_gui|Rocky Linux 9.3 Gnome (Desktop)|https://download.rockylinux.org/pub/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-boot.iso"
    "rocky_gui|Rocky Linux 8.9 Gnome (Desktop)|https://download.rockylinux.org/pub/rocky/8.9/isos/x86_64/Rocky-8.9-x86_64-boot.iso"
    "mint_gui|Linux Mint 21.3 Cinnamon (Desktop)|https://mirrors.edge.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
    "mint_gui|Linux Mint 21.2 Cinnamon (Desktop)|https://mirrors.edge.kernel.org/linuxmint/stable/21.2/linuxmint-21.2-cinnamon-64bit.iso"
    "opensuse_gui|openSUSE Leap 15.5 (Desktop)|https://download.opensuse.org/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64.iso"
    "opensuse_gui|openSUSE Leap 15.4 (Desktop)|https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64.iso"
  )
else
  # Lista de distros con Cloud-Init
  DISTROS=(
    "ubuntu_cloud|Ubuntu 22.04 Cloud-Init|https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
    "ubuntu_cloud|Ubuntu 20.04 Cloud-Init|https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img"
    "debian_cloud|Debian 12 Cloud-Init|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    "debian_cloud|Debian 11 Cloud-Init|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
    "rocky_cloud|Rocky Linux 9 Cloud-Init|https://download.rockylinux.org/pub/rocky/9/cloud/x86_64/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
    "rocky_cloud|Rocky Linux 8 Cloud-Init|https://download.rockylinux.org/pub/rocky/8/cloud/x86_64/images/Rocky-8-GenericCloud.latest.x86_64.qcow2"
    "almalinux_cloud|AlmaLinux 9 Cloud-Init|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
    "almalinux_cloud|AlmaLinux 8 Cloud-Init|https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
  )
fi

# Crear menú con whiptail
MENU_OPTIONS=()
INDEX=0
for entry in "${DISTROS[@]}"; do
  NAME=$(echo "$entry" | cut -d"|" -f2)
  MENU_OPTIONS+=("$INDEX" "$NAME")
  URLS[$INDEX]="$entry"
  ((INDEX++))
done

CHOICE=$(whiptail --title "Descarga de ISO Linux" \
  --menu "Selecciona una versión para descargar:" 25 78 15 \
  "${MENU_OPTIONS[@]}" \
  3>&1 1>&2 2>&3)

[ $? -ne 0 ] && echo "Cancelado." && exit 1

SELECTED="${URLS[$CHOICE]}"
NAME=$(echo "$SELECTED" | cut -d"|" -f2)
URL=$(echo "$SELECTED" | cut -d"|" -f3)
FILENAME=$(basename "$URL")

# Descargar ISO si no existe
if [ -f "$ISO_DIR/$FILENAME" ]; then
  echo "ℹ️ La imagen ya existe: $ISO_DIR/$FILENAME"
else
  echo "⬇️ Descargando $NAME..."
  wget -O "$ISO_DIR/$FILENAME" "$URL"
fi

echo "✅ Imagen lista: $ISO_DIR/$FILENAME"
