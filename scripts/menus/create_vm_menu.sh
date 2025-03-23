#!/bin/bash

# ==========================================================
# ProxMenu - VM Creation Menu
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

show_proxmenux_logo

while true; do
    OPTION=$(whiptail --title "$(translate "Create VM Menu")" --menu "$(translate "Select a VM template to create:")" 18 70 5 \
        "1" "$(translate "Synology DSM Virtual Machine")" \
        "2" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

    case $OPTION in
        1)
            msg_info2 "$(translate "Running script:") $(translate "Synology DSM VM Creator")..."
            bash <(curl -s "$REPO_URL/scripts/vm/synology.sh")
            if [ $? -ne 0 ]; then
                msg_warn "$(translate "Operation cancelled or failed.")"
                sleep 2
            fi
            ;;
        2) 
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") 
            ;;
        *) 
            exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") 
            ;;
    esac
done