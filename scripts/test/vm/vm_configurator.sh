#!/usr/bin/env bash

# ================================================
# VM Configuration Module - ProxMenux
# ================================================



BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
  source "$UTILS_FILE"
fi

load_language
initialize_cache



function generate_mac() {
  local GEN_MAC="02"
  for i in {1..5}; do
    BYTE=$(printf "%02X" $((RANDOM % 256)))
    GEN_MAC="${GEN_MAC}:${BYTE}"
  done
  echo "$GEN_MAC"
}

function load_default_vm_config() {
  local os_type="$1"

  VMID=$(pvesh get /cluster/nextid 2>/dev/null || echo "100")
  MAC=$(generate_mac)

  case "$os_type" in
    "nas")
      HN="synology-nas"
      CORE_COUNT="2"
      RAM_SIZE="8192"
      MACHINE=" -machine q35"
      BIOS_TYPE=" -bios ovmf"
      START_VM="no"
      ;;
    "windows")
      HN="windows-vm"
      CORE_COUNT="4"
      RAM_SIZE="8192"
      MACHINE=" -machine q35"
      BIOS_TYPE=" -bios ovmf"
      START_VM="no"
      ;;
    "linux")
      HN="linux-vm"
      CORE_COUNT="2"
      RAM_SIZE="4096"
      MACHINE=" -machine q35"
      BIOS_TYPE=" -bios ovmf"
      START_VM="no"
      ;;
    "lite")
      HN="lite-vm"
      CORE_COUNT="1"
      RAM_SIZE="2048"
      MACHINE=""
      BIOS_TYPE=" -bios seabios"
      START_VM="no"
      ;;
    *)
      HN="vm-proxmenux"
      CORE_COUNT="2"
      RAM_SIZE="2048"
      MACHINE=" -machine q35"
      BIOS_TYPE=" -bios ovmf"
      START_VM="no"
      ;;
  esac

  CPU_TYPE=" -cpu host"
  BRG="vmbr0"
  VLAN=""
  MTU=""
  SERIAL_PORT="socket"
  FORMAT=""
  DISK_CACHE=""
}

function apply_default_vm_config() {
  echo -e "${DEF}$(translate "Applying default VM configuration")${CL}"
  echo -e "${DGN}$(translate "Virtual Machine ID")${CL}: ${BGN}$VMID${CL}"
  echo -e "${DGN}$(translate "Hostname")${CL}: ${BGN}$HN${CL}"
  echo -e "${DGN}$(translate "CPU Cores")${CL}: ${BGN}$CORE_COUNT${CL}"
  echo -e "${DGN}$(translate "RAM Size")${CL}: ${BGN}$RAM_SIZE MiB${CL}"
  echo -e "${DGN}$(translate "Machine Type")${CL}: ${BGN}${MACHINE/ -machine /}${CL}"
  echo -e "${DGN}$(translate "BIOS Type")${CL}: ${BGN}${BIOS_TYPE/ -bios /}${CL}"
  echo -e "${DGN}$(translate "CPU Model")${CL}: ${BGN}${CPU_TYPE/ -cpu /}${CL}"
  echo -e "${DGN}$(translate "Network Bridge")${CL}: ${BGN}$BRG${CL}"
  echo -e "${DGN}$(translate "MAC Address")${CL}: ${BGN}$MAC${CL}"
  echo -e "${DGN}$(translate "Start VM after creation")${CL}: ${BGN}$START_VM${CL}"
  echo -e
}



function configure_vm_advanced() {
  # VMID
  while true; do
    VMID=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set Virtual Machine ID")" 8 58 "$VMID" --title "VM ID" 3>&1 1>&2 2>&3) || return
    if [ -z "$VMID" ]; then continue; fi
    if qm status "$VMID" &>/dev/null || pct status "$VMID" &>/dev/null; then
      msg_error "$(translate "ID already in use. Please choose another.")"
    else
      break
    fi
  done

  # Hostname
  HN=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set Hostname")" 8 58 "$HN" --title "Hostname" 3>&1 1>&2 2>&3) || return
  [[ -z "$HN" ]] && HN="vm-proxmenux"

  # Machine Type
  MACHINE_TYPE=$(whiptail --backtitle "ProxMenux" --title "$(translate "MACHINE TYPE")" --radiolist \
    "$(translate "Select machine type")" 10 60 2 \
    "q35"     "QEMU q35" ON \
    "i440fx"  "Legacy i440fx" OFF 3>&1 1>&2 2>&3) || return

  if [ "$MACHINE_TYPE" = "q35" ]; then
    MACHINE=" -machine q35"
    FORMAT=""
  else
    MACHINE=""
    FORMAT=",efitype=4m"
  fi

  # BIOS
  BIOS=$(whiptail --backtitle "ProxMenux" --title "$(translate "BIOS TYPE")" --radiolist \
    "$(translate "Choose BIOS type")" 10 60 2 \
    "ovmf"    "UEFI (OVMF)" ON \
    "seabios" "Legacy BIOS (SeaBIOS)" OFF 3>&1 1>&2 2>&3) || return

  BIOS_TYPE=" -bios $BIOS"

  # CPU Type
  CPU_CHOICE=$(whiptail --backtitle "ProxMenux" --title "$(translate "CPU MODEL")" --radiolist \
    "$(translate "Select CPU model")" 10 60 2 \
    "host"  "Host (recommended)" ON \
    "kvm64" "Generic KVM64" OFF 3>&1 1>&2 2>&3) || return

  if [ "$CPU_CHOICE" = "host" ]; then
    CPU_TYPE=" -cpu host"
  else
    CPU_TYPE=" -cpu kvm64"
  fi

  # Core Count
  CORE_COUNT=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Number of CPU cores")" 8 58 "$CORE_COUNT" --title "CPU Cores" 3>&1 1>&2 2>&3) || return

  # RAM
  RAM_SIZE=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Amount of RAM in MiB")" 8 58 "$RAM_SIZE" --title "RAM" 3>&1 1>&2 2>&3) || return

  # Bridge
  BRG=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set network bridge")" 8 58 "$BRG" --title "Network Bridge" 3>&1 1>&2 2>&3) || return

  # MAC
  MAC_INPUT=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set MAC Address (leave empty for random)")" 8 58 "$MAC" --title "MAC Address" 3>&1 1>&2 2>&3) || return
  if [[ -z "$MAC_INPUT" ]]; then
    MAC=$(generate_mac)
  else
    MAC="$MAC_INPUT"
  fi

  # VLAN
  VLAN_INPUT=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set VLAN Tag (leave empty for none)")" 8 58 --title "VLAN" 3>&1 1>&2 2>&3) || return
  VLAN=""
  [[ -n "$VLAN_INPUT" ]] && VLAN=",tag=$VLAN_INPUT"

  # MTU
  MTU_INPUT=$(whiptail --backtitle "ProxMenux" --inputbox "$(translate "Set MTU size (leave empty for default)")" 8 58 --title "MTU" 3>&1 1>&2 2>&3) || return
  MTU=""
  [[ -n "$MTU_INPUT" ]] && MTU=",mtu=$MTU_INPUT"

  # Start VM
  if (whiptail --backtitle "ProxMenux" --title "$(translate "START VM")" --yesno "$(translate "Start VM when finished?")" 10 60); then
    START_VM="yes"
  else
    START_VM="no"
  fi

  msg_ok "$(translate "Advanced configuration completed.")"
}
