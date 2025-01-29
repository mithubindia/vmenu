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
REPO_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/menus"
UTILS_URL="https://raw.githubusercontent.com/MacRimi/ProxMenux/main/scripts/utils.sh"
BASE_DIR="/usr/local/share/proxmenux"
CACHE_FILE="$BASE_DIR/cache.json"
VENV_PATH="/opt/googletrans-env"
LANGUAGE=$(jq -r '.language // "en"' "$BASE_DIR/config.json" 2>/dev/null)
# ==========================================================

# Try to load utils.sh from GitHub
if ! source <(curl -sSf "$UTILS_URL"); then
    echo "$(translate 'Error: Could not load utils.sh from') $UTILS_URL"
    exit 1
fi


    while true; do
        OPTION=$(whiptail --title "$(translate "Disk and Storage Menu")" --menu "$(translate "Select an option:")" 15 60 3 \
            "1" "$(translate "Add Disk Passthrough to a VM")" \
            "2" "$(translate "Import Disk Image to a VM")" \
            "3" "$(translate "Return to Main Menu")" 3>&1 1>&2 2>&3)

        case $OPTION in
            1)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Disk Passthrough")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/disk-passthrough.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            2)
                echo -e "\033[33m[INFO] $(translate "Running script:") $(translate "Import Disk Image")...\033[0m"
                bash <(curl -s "$REPO_URL/scripts/import-disk-image.sh")
                if [ $? -ne 0 ]; then
                    msg_info "$(translate "Operation cancelled.")"
                    sleep 2
                fi
                ;;
            3)
                return
                ;;
            *)
                return
                ;;
        esac
    done
