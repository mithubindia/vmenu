#!/usr/bin/env bash

# ================================================
# ProxMenux - Create VM Entry Point
# ================================================
# Author : MacRimi
# ================================================

BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"
VM_CONFIG="./vm_configurator.sh"
DISK_SELECTOR="./disk_selector.sh"
VM_CREATOR="./vm_creator.sh"
#LINUX_ISO="./select_linux_iso.sh"
GUEST_AGENT="./guest_agent_config.sh"


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

# Step 1 - Select OS Type
OS_TYPE=$(whiptail --title "ProxMenux" --menu "$(translate "Select the type of system to install")" 15 60 4 \
  "nas"     "$(translate "Create VM System NAS")" \
  "windows" "$(translate "Create VM System Windows")" \
  "linux"   "$(translate "Create VM System Linux")" \
  "lite"    "$(translate "Create VM System Others (based Linux)")" 3>&1 1>&2 2>&3)

[[ -z "$OS_TYPE" ]] && clear && exit


if [[ "$OS_TYPE" == "nas" ]]; then
  header_info
  source ./select_nas_iso.sh
  select_nas_iso || exit 1
fi


# Si es Windows, invocar selección de ISO
if [[ "$OS_TYPE" == "windows" ]]; then
  header_info
  source ./select_windows_iso.sh
  select_windows_iso || exit 1
fi


# Si es Linux, invocar selección de ISO
if [[ "$OS_TYPE" == "linux" ]]; then
  header_info
  source ./select_linux_iso.sh
  select_linux_iso || exit 1
fi





# Step 2 - Default or Advanced config
if (whiptail --title "ProxMenux" --yesno "$(translate "Use Default Settings?")" --no-button "$(translate "Advanced")" 10 60); then
  header_info
  load_default_vm_config "$OS_TYPE"
  apply_default_vm_config
else
  header_info
  echo -e "${CUS}$(translate "Using advanced configuration")${CL}"
  configure_vm_advanced "$OS_TYPE"
fi

# Step 3 - Disk selection
select_disk_type
if [[ -z "$DISK_TYPE" ]]; then
  msg_error "$(translate "Disk type selection failed or cancelled")"
  exit 1
fi

# Step 4 - Create VM
create_vm

# Step 5 - Guest Agent integration
configure_guest_agent
