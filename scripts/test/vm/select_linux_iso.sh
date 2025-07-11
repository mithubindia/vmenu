#!/usr/bin/env bash

# vmenu - Linux ISO Selector (No download yet)

BASE_DIR="/usr/local/share/vmenu"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache



function select_linux_iso() {

ISO_DIR="/var/lib/vz/template/iso"
mkdir -p "$ISO_DIR"


DISTROS=(
  "Ubuntu 22.04 LTS Desktop|Desktop|vmenu|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-desktop-amd64.iso"
  "Ubuntu 20.04 LTS Desktop|Desktop|vmenu|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-desktop-amd64.iso"
  "Ubuntu 22.04 LTS Server (CLI)|CLI|vmenu|https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  "Ubuntu 20.04 LTS Server (CLI)|CLI|vmenu|https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
  "Debian 12 Gnome (Desktop)|Desktop|vmenu|https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-DVD-1.iso"
  "Debian 11 Gnome (Desktop)|Desktop|vmenu|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-dvd/debian-11.9.0-amd64-DVD-1.iso"
  "Debian 12 Netinst (CLI)|CLI|vmenu|https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
  "Debian 11 Netinst (CLI)|CLI|vmenu|https://cdimage.debian.org/debian-cd/11.9.0/amd64/iso-cd/debian-11.9.0-amd64-netinst.iso"
  "Fedora Workstation 39|Desktop|vmenu|https://download.fedoraproject.org/pub/fedora/linux/releases/39/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-39-1.5.iso"
  "Fedora Workstation 38|Desktop|vmenu|https://download.fedoraproject.org/pub/fedora/linux/releases/38/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-38-1.6.iso"
  "Rocky Linux 9.3 Gnome|Desktop|vmenu|https://download.rockylinux.org/pub/rocky/9.3/isos/x86_64/Rocky-9.3-x86_64-boot.iso"
  "Rocky Linux 8.9 Gnome|Desktop|vmenu|https://download.rockylinux.org/pub/rocky/8.9/isos/x86_64/Rocky-8.9-x86_64-boot.iso"
  "Linux Mint 21.3 Cinnamon|Desktop|vmenu|https://mirrors.edge.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
  "Linux Mint 21.2 Cinnamon|Desktop|vmenu|https://mirrors.edge.kernel.org/linuxmint/stable/21.2/linuxmint-21.2-cinnamon-64bit.iso"
  "openSUSE Leap 15.5|Desktop|vmenu|https://download.opensuse.org/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64.iso"
  "openSUSE Leap 15.4|Desktop|vmenu|https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64.iso"
  "Alpine Linux 3.19|CLI|vmenu|https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.1-x86_64.iso"
  "Kali Linux 2024.1|Desktop|vmenu|https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
  "Manjaro 23.1 GNOME|Desktop|vmenu|https://download.manjaro.org/gnome/23.1/manjaro-gnome-23.1-231017-linux65.iso"
  "Arch Linux   (automatizado)|Cloud-ini|Helper Scripts|https://raw.githubusercontent.com/community-scripts/VirtuliservmenuVE/main/vm/archlinux-vm.sh"
  "Debian 12    (automatizado)|Cloud-ini|Helper Scripts|https://raw.githubusercontent.com/community-scripts/VirtuliservmenuVE/main/vm/debian-vm.sh"
  "Ubuntu 22.04 (automatizado)|Cloud-ini|Helper Scripts|https://raw.githubusercontent.com/community-scripts/VirtuliservmenuVE/main/vm/ubuntu2204-vm.sh"
  "Ubuntu 24.04 (automatizado)|Cloud-ini|Helper Scripts|https://raw.githubusercontent.com/community-scripts/VirtuliservmenuVE/main/vm/ubuntu2404-vm.sh"
  "Ubuntu 24.10 (automatizado)|Cloud-ini|Helper Scripts|https://raw.githubusercontent.com/community-scripts/VirtuliservmenuVE/main/vm/ubuntu2410-vm.sh"
)

MENU_OPTIONS=()
INDEX=0
for entry in "${DISTROS[@]}"; do
  IFS='|' read -r NAME TYPE SOURCE URL <<< "$entry"
  LINE=$(printf "%-35s │ %-10s │ %s" "$NAME" "$TYPE" "$SOURCE")
  MENU_OPTIONS+=("$INDEX" "$LINE")
  URLS[$INDEX]="$entry"
  ((INDEX++))
done

HEADER="%-41s │ %-10s │ %s"
HEADER_TEXT=$(printf "$HEADER" "     Versión" "Tipo" "Fuente")

CHOICE=$(whiptail --title "vmenu - Linux ISO" \
  --menu "$(translate "Select the Linux distribution to install"):\n\n$HEADER_TEXT" 20 80 10 \
  "${MENU_OPTIONS[@]}" \
  3>&1 1>&2 2>&3)

[[ $? -ne 0 ]] && echo "Cancelled" && exit 1

SELECTED="${URLS[$CHOICE]}"
IFS='|' read -r ISO_NAME ISO_TYPE SOURCE ISO_URL <<< "$SELECTED"
ISO_FILE=$(basename "$ISO_URL")
ISO_PATH="$ISO_DIR/$ISO_FILE"

# Exportar para que los use el script principal
export ISO_NAME
export ISO_TYPE
export ISO_URL
export ISO_FILE
export ISO_PATH


}