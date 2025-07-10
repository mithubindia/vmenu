#!/usr/bin/env bash

# ProxMenuX - Virtual Machine Creator Script
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Last Updated: 07/05/2025
# This script is part of the central ProxMenux VM creation module. It allows users
# to create virtual machines (VMs) in Proxmox VE using either default or advanced
# configurations, streamlining the deployment of Linux, Windows, and other systems.
#
# Key features:
# - Supports both virtual disk creation and physical disk passthrough.
# - Automates CPU, RAM, BIOS, network and storage configuration.
# - Provides a user-friendly menu to select OS type, ISO image and disk interface.
# - Automatically generates a detailed and styled HTML description for each VM.
#
# All operations are designed to simplify and accelerate VM creation in a 
# consistent and maintainable way, using ProxMenux standards.



REPO_URL="https://raw.githubusercontent.com/mithubindia/vmenu/main"
VM_REPO="$REPO_URL/scripts/vm"
ISO_REPO="$REPO_URL/scripts/vm"
MENU_REPO="$REPO_URL/scripts/menus"
BASE_DIR="/usr/local/share/vmenu"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

[[ -f "$UTILS_FILE" ]] && source "$UTILS_FILE"


source <(curl -s "$VM_REPO/vm_configurator.sh")
source <(curl -s "$VM_REPO/disk_selector.sh")
source <(curl -s "$VM_REPO/vm_creator.sh")



if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache



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

# MAIN EXECUTION

#header_info
#echo -e "\n Loading..."
#sleep 1




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
    --menu "\n$(translate "Choose the type of virtual system to install:")" 20 70 10 \
    1 "$(translate "Create") VM System NAS" \
    2 "$(translate "Create") VM System Windows" \
    3 "$(translate "Create") VM System Linux" \
    4 "$(translate "Create") VM System macOS (OSX-PROXMOX)" \
    5 "$(translate "Create") VM System Others (based Linux)" \
    6 "$(translate "Return to Main Menu")" \
    3>&1 1>&2 2>&3)


  [[ $? -ne 0 || "$OS_TYPE" == "6" ]] && exec bash <(curl -s "$MENU_REPO/main_menu.sh")

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
      whiptail --title "OSX-PROXMOX" --yesno "$(translate "This is an external script that creates a macOS VM in Proxmox VE in just a few steps, whether you are using AMD or Intel hardware.")\n\n$(translate "The script clones the osx-proxmox.com repository and once the setup is complete, the server will automatically reboot.")\n\n$(translate "Make sure there are no critical services running as they will be interrupted. Ensure your server can be safely rebooted.")\n\n$(translate  "Visit https://osx-proxmox.com for more information.")\n\n$(translate "Do you want to run the script now?")" 24 70
      if [[ $? -eq 0 ]]; then
        bash -c "$(curl -fsSL https://install.osx-proxmox.com)"
      fi
      continue
      ;;
    5)
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

