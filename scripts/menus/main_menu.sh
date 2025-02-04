#!/bin/bash

# ==========================================================
# ProxMenu - A menu-driven script for Proxmox VE management
# ==========================================================
# Author      : MacRimi
# Copyright   : (c) 2024 MacRimi
# License     : MIT (https://raw.githubusercontent.com/MacRimi/ProxMenux/main/LICENSE)
# Version     : 1.0
# Last Updated: 28/01/2025
# ==========================================================


# Configuration ============================================
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main"
BASE_DIR="/usr/local/share/proxmenux"
UTILS_FILE="$BASE_DIR/utils.sh"
VENV_PATH="/opt/googletrans-env"

if [[ -f "$UTILS_FILE" ]]; then
    source "$UTILS_FILE"
fi

load_language
initialize_cache
# ==========================================================


show_menu() {
    while true; do
        OPTION=$(whiptail --title "$(translate "Main Menu")" --menu "$(translate "Select an option:")" 20 70 8 \
            "1" "$(translate "GPUs and Coral-TPU")" \
            "2" "$(translate "Hard Drives, Disk Images, and Storage")" \
            "3" "$(translate "Network")" \
            "4" "$(translate "Settings")" \
            "5" "$(translate "Exit")" 3>&1 1>&2 2>&3)



    case $OPTION in
        1) exec bash <(curl -s "$REPO_URL/scripts/menus/hw_grafics_menu.sh") ;;
        2) exec bash <(curl -s "$REPO_URL/scripts/menus/storage_menu.sh") ;;
        3) exec bash <(curl -s "$REPO_URL/scripts/repair_network.sh") ;;
        4) exec bash <(curl -s "$REPO_URL/scripts/menus/config_menu.sh") ;;
        5) clear; msg_ok "$(translate "Thank you for using ProxMenu. Goodbye!")"; exit 0 ;;
        *) msg_warn "$(translate "Invalid option")"; sleep 2 ;;
    esac
    
done
}

# Main flow
show_menu

