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


    while true; do
        OPTION=$(whiptail --title "$(translate "Disk and Storage Menu")" --menu "$(translate "Select an option:")" 20 70 8 \
            "1" "$(translate "Add Disk Passthrough to a VM")" \
            "2" "$(translate "Import Disk Image to a VM")" \
            "3" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                msg_info2 "$(translate "Running script:") $(translate "Disk") Passthrough..."
                bash <(curl -s "$REPO_URL/scripts/disk-passthrough.sh")
                if [ $? -ne 0 ]; then
                    msg_warn "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            2)
                msg_info2 "$(translate "Running script:") $(translate "Import Disk Image")..."
                bash <(curl -s "$REPO_URL/scripts/import-disk-image.sh")
                if [ $? -ne 0 ]; then
                    msg_warn "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
                
            3) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
            *) exec bash <(curl -s "$REPO_URL/scripts/menus/main_menu.sh") ;;
        esac
    done
