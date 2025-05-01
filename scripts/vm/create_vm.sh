#!/usr/bin/env bash

# ================================================
# ProxMenux - Create VM Entry Point
# ================================================
# Author : MacRimi
# ================================================

REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
VM_REPO="$REPO_URL/scripts/vm"
ISO_REPO="$REPO_URL/scripts/vm"
MENU_REPO="$REPO_URL/scripts/menus"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

[[ -f "$UTILS_FILE" ]] && source "$UTILS_FILE"


source <(curl -s "$VM_REPO/vm_configurator.sh")
source <(curl -s "$VM_REPO/disk_selector.sh")
source <(curl -s "$VM_REPO/vm_creator.sh")
source <(curl -s "$VM_REPO/guest_agent_config.sh")


if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache

# Load modules
[[ -f "$UTILS_FILE" ]] && source "$UTILS_FILE"
[[ -f "$VM_CONFIG" ]] && source "$VM_CONFIG"
[[ -f "$DISK_SELECTOR" ]] && source "$DISK_SELECTOR"
[[ -f "$VM_CREATOR" ]] && source "$VM_CREATOR"
[[ -f "$LINUX_ISO" ]] && source "$LINUX_ISO"
[[ -f "$GUEST_AGENT" ]] && source "$GUEST_AGENT"




function header_info() {
  clear
  show_proxmenux_logo
  echo -e "${BL}╔═══════════════════════════════════════════════╗${CL}"
  echo -e "${BL}║                                               ║${CL}"
  echo -e "${BL}║${YWB}             ProxMenux VM Creator              ${BL}║${CL}"
  echo -e "${BL}║                                               ║${CL}"
  echo -e "${BL}╚═══════════════════════════════════════════════╝${CL}"
  echo -e
}

# ==========================================================
# MAIN EXECUTION
# ==========================================================

header_info
echo -e "\n Loading..."
sleep 1




function start_vm_configuration() {

  if (whiptail --title "ProxMenux" --yesno "$(translate "Use Default Settings?")" --no-button "$(translate "Advanced")" 10 60); then
    header_info
    load_default_vm_config "$OS_TYPE"

    if [[ -z "$HN" ]]; then
      HN=$(whiptail --inputbox "$(translate "Enter a name for the new virtual machine:")" 10 60 --title "VM Hostname" 3>&1 1>&2 2>&3)
      [[ -z "$HN" ]] && HN="custom-vm"
    fi

    apply_default_vm_config
  else
    header_info
    echo -e "${CUS}$(translate "Using advanced configuration")${CL}"
    configure_vm_advanced "$OS_TYPE"
  fi
}



while true; do
  OS_TYPE=$(dialog --backtitle "ProxMenux" \
    --title "$(translate "Select System Type")" \
    --menu "$(translate "Choose the type of virtual system to install:")" 18 64 8 \
    1 "$(translate "Create") VM System NAS" \
    2 "$(translate "Create") VM System Windows" \
    3 "$(translate "Create") VM System Linux" \
    4 "$(translate "Create") VM System Others (based Linux)" \
    5 "$(translate "Return to Main Menu")" \
    3>&1 1>&2 2>&3)


  [[ $? -ne 0 || "$OS_TYPE" == "5" ]] && exec bash <(curl -s "$MENU_REPO/main_menu.sh")

  case "$OS_TYPE" in
    1)
      source <(curl -fsSL "$ISO_REPO/select_nas_iso.sh") && select_nas_iso || continue
      ;;
    2)
      source <(curl -fsSL "$ISO_REPO/select_windows_iso.sh") && select_windows_iso || continue
      ;;
    3)
      source <(curl -fsSL "$ISO_REPO/select_linux_iso.sh") && select_linux_iso || continue
      ;;
    4)
      source <(curl -fsSL "$ISO_REPO/select_linux_iso.sh") && select_linux_other_scripts || continue
      ;;
  esac


  if ! confirm_vm_creation; then
    continue  
  fi


  start_vm_configuration || continue


  select_disk_type
  if [[ -z "$DISK_TYPE" ]]; then
    msg_error "$(translate "Disk type selection failed or cancelled")"
    continue  
  fi

  create_vm
  break
done





function start_vm_configuration() {

  if (whiptail --title "ProxMenux" --yesno "$(translate "Use Default Settings?")" --no-button "$(translate "Advanced")" 10 60); then
    header_info
    load_default_vm_config "$OS_TYPE"

    if [[ -z "$HN" ]]; then
      HN=$(whiptail --inputbox "$(translate "Enter a name for the new virtual machine:")" 10 60 --title "VM Hostname" 3>&1 1>&2 2>&3)
      [[ -z "$HN" ]] && HN="custom-vm"
    fi

    apply_default_vm_config
  else
    header_info
    echo -e "${CUS}$(translate "Using advanced configuration")${CL}"
    configure_vm_advanced "$OS_TYPE"
  fi
}

